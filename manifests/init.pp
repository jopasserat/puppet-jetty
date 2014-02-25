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
# Nothing.
#
# == Sample Usage:
#
#   class {'jetty::deploy':
#     source => /tmp/myapp.war,
#     war => app.war,
#   }
#
class jetty(
  $version                = hiera('jetty::version'),
  $group                  = hiera('jetty::group', 'jetty'),
  $user                   = hiera('jetty::user', 'jetty'),
  $home                   = hiera('jetty::home', '/opt/jetty'),
  $log                    = hiera('jetty::log', '/var/log/jetty'),
  $tmp                    = hiera('jetty::tmp', '/tmp'),
  $java_properties        = hiera('jetty::java_properties', undef),
  $jetty_properties       = hiera('jetty::jetty_properties', undef),
  $create_work_dir        = hiera('jetty::create_work_dir', false),
  $remove_demo_base       = hiera('jetty::remove_demo_base', true),
) {

  require java

  singleton_packages("unzip", "wget")

  group { "${group}":
    ensure => "present",
  }

  user { "${user}":
    ensure => "present",
    groups => $group,
    managehome => true,
    shell  => '/bin/bash',
    require => Group["${group}"],
  }

  exec { "download jetty":
    cwd => $tmp,
    command => "/usr/bin/wget http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${version}/jetty-distribution-${version}.zip",
    creates => "${tmp}/jetty-distribution-${version}.zip",
    notify => Exec['unzip jetty'],
  }

  exec { "unzip jetty":
    cwd => $tmp,
    command => "/usr/bin/unzip jetty-distribution-${version}.zip -d /opt",
    creates => "/opt/jetty-distribution-${version}",
  }

  file { "/opt/jetty-distribution-${version}":
    ensure => directory,
    owner => $user,
    group => $group,
    recurse => true,
    require => [User["${user}"], Exec['unzip jetty']],
  }

  file { "${home}":
    require => File["/opt/jetty-distribution-${version}"],
    ensure => 'link',
    target => "/opt/jetty-distribution-${version}",
  }

  file { "/etc/init.d/jetty":
    require => File["${home}"],
    ensure => 'link',
    target => "${home}/bin/jetty.sh",
  }

  file { "${log}":
    ensure => directory,
    owner => $user,
    group => $group,
    recurse => true,
    require => User["${user}"],
  }

  service { 'jetty':
    require => File["/etc/init.d/jetty"],
    enable => true,
    ensure => running,
    hasrestart => true,
    hasstatus => false,
  }

  if ($create_work_dir) {
    file { "${home}/work":
      path => "${home}/work",
      ensure => directory,
      owner => $user,
      group => $group,
      require => [User["${user}"], File["${home}"]],
    }
  }

  if ($remove_demo_base) {
    file { "${home}/demo-base":
      ensure => absent,
      force => true,
      require => File["${home}"],
    }
  }

  if ($java_properties != '' or $jetty_properties != '') {

    file { "/etc/default/jetty":
      path => "/etc/default/jetty",
      ensure => present,
    }

    if ($java_properties != '') {
      $java_properties.each |$key, $value| {
        file_line { "java_properties_${key}":
          path => "/etc/default/jetty",
          line => "${key}=${value}",
          match => "^(${key}=).*$",
          require => File["/etc/default/jetty"],
          notify => Service['jetty'],
        }
      }
    }

    if ($jetty_properties != '') {
      $jetty_properties.each |$key, $value| {
        file_line { "jetty_properties_${key}":
          path => "/etc/default/jetty",
          line => "${key}=${value}",
          match => "^(${key}=).*$",
          require => File["/etc/default/jetty"],
          notify => Service['jetty'],
        }
      }
    }
  }
}