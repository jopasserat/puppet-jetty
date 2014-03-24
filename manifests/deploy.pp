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
# == Authors
#
# Gamaliel Sick
#
# == Copyright
#
# Copyright 2014 Gamaliel Sick, unless otherwise noted.
#
class jetty::deploy(
  $source       = hiera('jetty::deploy::source', undef),
  $war          = hiera('jetty::deploy::war', undef),
) {

  file { "jetty_war_${war}":
    ensure => present,
    path   => "${jetty::home}/webapps/${war}",
    owner  => $jetty::user,
    group  => $jetty::group,
    source => $source,
    notify => Service['jetty'],
  }
}