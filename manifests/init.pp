# = Class: jetty
#
# This class installs and configure Jetty Web server.
#
# == Parameters:
#
# $version:: The version of Jetty to download.
#
# $group::  Group who own Jetty.
#
# $user::  User who own Jetty.
#
# $home::  Jetty home path.
#
# $log::  Jetty log path.
#
# $tmp::  Temp directory.
#
# $java_properties::  Java properties for the jvm.
#
# $jetty_properties::  Jetty properties.
#
# $create_work_dir::  If create 'work' directory.
#
# $remove_demo_base::  If remove 'demo-base' directory.
#
# == Requires:
#
# Java
#
# == Sample Usage:
#
#   class {'jetty':
#     version => '9.1.4.v20140401',
#   }
#
# == Authors
#
# Gamaliel Sick
#
# == Copyright
#
# Copyright 2014 Gamaliel Sick, unless otherwise noted.
#
class jetty(
  $version                = hiera('jetty::version'),
  $group                  = hiera('jetty::group', 'jetty'),
  $user                   = hiera('jetty::user', 'jetty'),
  $home                   = hiera('jetty::home', '/opt/jetty'),
  $log                    = hiera('jetty::log', '/var/log/jetty'),
  $tmp                    = hiera('jetty::tmp', '/tmp'),
  $java_properties        = hiera('jetty::java_properties', undef),
  $jetty_properties       = hiera('jetty::jetty_properties', {}),
  $create_work_dir        = hiera('jetty::create_work_dir', false),
  $remove_demo_base       = hiera('jetty::remove_demo_base', true),
) {

  $default_jetty_properties = {
    'JETTY_HOME' => $home,
    'JETTY_USER' => $user,
    'JETTY_PORT' => 8080,
    'JETTY_HOST' => '127.0.0.1',
    'JETTY_LOGS' => $log,
  }

  validate_hash($jetty_properties)
  $final_jetty_properties = merge($default_jetty_properties, $jetty_properties)

  require java

  singleton_packages('unzip', 'wget')

  group { 'jetty group':
    ensure => present,
    name   => $group,
  }

  user { 'jetty user':
    ensure     => present,
    name       => $user,
    groups     => $group,
    managehome => true,
    shell      => '/bin/bash',
    require    => Group['jetty group'],
  }

  exec { 'download jetty':
    cwd     => $tmp,
    path    => '/bin:/usr/bin',
    command => "wget http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${version}/jetty-distribution-${version}.zip",
    creates => "${tmp}/jetty-distribution-${version}.zip",
    notify  => Exec['unzip jetty'],
    require => Package['wget'],
  }

  exec { 'unzip jetty':
    cwd     => $tmp,
    path    => '/bin:/usr/bin',
    command => "unzip jetty-distribution-${version}.zip -d /opt",
    creates => "/opt/jetty-distribution-${version}",
    require => Package['unzip'],
  }

  file { 'jetty directory':
    ensure  => directory,
    path    => "/opt/jetty-distribution-${version}",
    owner   => $user,
    group   => $group,
    recurse => true,
    require => [User['jetty user'], Exec['unzip jetty']],
  }

  file { 'jetty home':
    ensure  => 'link',
    path    => $home,
    target  => "/opt/jetty-distribution-${version}",
    require => File['jetty directory'],
  }

  file { 'jetty init':
    ensure  => 'link',
    path    => '/etc/init.d/jetty',
    target  => "${home}/bin/jetty.sh",
    require => File['jetty home'],
  }

  file { 'jetty log':
    ensure  => directory,
    path    => $log,
    owner   => $user,
    group   => $group,
    recurse => true,
    require => User['jetty user'],
  }

  service { 'jetty':
    ensure     => running,
    name       => 'jetty',
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
    require    => File['jetty init'],
  }

  if ($create_work_dir) {
    file { 'jetty work':
      ensure  => directory,
      path    => "${home}/work",
      owner   => $user,
      group   => $group,
      require => [User['jetty user'], File['jetty home']],
    }
  }

  if ($remove_demo_base) {
    file { 'jetty demo':
      ensure  => absent,
      path    => "${home}/demo-base",
      force   => true,
      require => File['jetty home'],
    }
  }

  file { 'jetty default':
    ensure => file,
    path   => '/etc/default/jetty',
    owner  => 'root',
    group  => 'root',
  }

  $final_jetty_properties.each |$key, $value| {
    file_line { "jetty_properties_${key}":
      path    => '/etc/default/jetty',
      line    => "${key}=${value}",
      match   => "^(${key}=).*$",
      require => File['jetty default'],
      notify  => Service['jetty'],
    }
  }

  if(!empty($java_properties)) {
    validate_hash($java_properties)

    $java_properties.each |$key, $value| {
      file_line { "java_properties_${key}":
        path    => '/etc/default/jetty',
        line    => "${key}=${value}",
        match   => "^(${key}=).*$",
        require => File['jetty default'],
        notify  => Service['jetty'],
      }
    }
  }
}