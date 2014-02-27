# = Class: jetty::deploy
#
# This class installs a war file in ${jetty::home}/webapps/.
#
# == Parameters:
#
# $source:: The path to the source file.
#
# $war::  The name of the war.
#
# == Requires:
#
# Jetty
#
# == Sample Usage:
#
#   class {'jetty::deploy':
#     source => /tmp/myapp.war,
#     war => app.war,
#   }
#
class jetty::deploy (
  $source       = hiera('jetty::deploy::source', undef),
  $war          = hiera('jetty::deploy::war', undef),
) {

  file { "${jetty::home}/webapps/${war}":
    ensure => present,
    owner  => "${jetty::user}",
    group  => "${jetty::group}",
    source => "${source}",
    notify => Service['jetty'],
  }
}