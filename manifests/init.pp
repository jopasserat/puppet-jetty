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
#     version => 9.1.3.v20140225,
#   }
#
# == Authors
#
# Gamaliel Sick
#
# == Copyright
#
# Copyright 2013 Gamaliel Sick, unless otherwise noted.
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
    'JETTY_HOME' => "${home}", 
    'JETTY_USER' => "${user}", 
    'JETTY_PORT' => 8080,
    'JETTY_HOST' => '127.0.0.1',
    'JETTY_LOGS' => "${log}",
  }

  validate_hash($jetty_properties)
  $final_jetty_properties = merge($default_jetty_properties, $jetty_properties)

  require java

  singleton_packages('unzip', 'wget')

  group { 'jetty group':
    name   => "${group}",
    ensure => present,
  }

  user { 'jetty user':
    name       => "${user}",
    ensure     => present,
    groups     => "${group}",
    managehome => true,
    shell      => '/bin/bash',
    require    => Group['jetty group'],
  }

  exec { 'download jetty':
    cwd     => "${tmp}",
    path    => '/bin:/usr/bin',
    command => "wget http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${version}/jetty-distribution-${version}.zip",
    creates => "${tmp}/jetty-distribution-${version}.zip",
    notify  => Exec['unzip jetty'],
    require => Package['wget'],
  }

  exec { "unzip jetty":
    cwd     => "${tmp}",
    command => "/usr/bin/unzip jetty-distribution-${version}.zip -d /opt",
    creates => "/opt/jetty-distribution-${version}",
    require => Package['unzip'],
  }

  file { 'jetty directory':
    path    => "/opt/jetty-distribution-${version}",
    ensure  => directory,
    owner   => "${user}",
    group   => "${group}",
    recurse => true,
    require => [User['jetty user'], Exec['unzip jetty']],
  }

  file { 'jetty home':
    path    => "${home}",
    require => File['jetty directory'],
    ensure  => 'link',
    target  => "/opt/jetty-distribution-${version}",
  }

  file { 'jetty init':
    path    => '/etc/init.d/jetty',
    require => File['jetty home'],
    ensure  => 'link',
    target  => "${home}/bin/jetty.sh",
  }

  file { 'jetty log':
    path    => "${log}",
    ensure  => directory,
    owner   => "${user}",
    group   => "${group}",
    recurse => true,
    require => User['jetty user'],
  }

  service { 'jetty service':
    name       => 'jetty',
    enable     => true,
    ensure     => running,
    hasrestart => true,
    hasstatus  => false,
    require    => File['jetty init'],
  }

  if ($create_work_dir) {
    file { 'jetty work':
      path    => "${home}/work",
      ensure  => directory,
      owner   => "${user}",
      group   => "${group}",
      require => [User['jetty user'], File['jetty home']],
    }
  }

  if ($remove_demo_base) {
    file { 'jetty demo':
      path    => "${home}/demo-base",
      ensure  => absent,
      force   => true,
      require => File['jetty home'],
    }
  }

  file { 'jetty default':
    path   => "/etc/default/jetty",
    ensure => present,
  }

  $final_jetty_properties.each |$key, $value| {
    file_line { "jetty_properties_${key}":
      path    => '/etc/default/jetty',
      line    => "${key}=${value}",
      match   => "^(${key}=).*$",
      require => File['jetty default'],
      notify  => Service['jetty service'],
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
        notify  => Service['jetty service'],
      }
    }
  }
}