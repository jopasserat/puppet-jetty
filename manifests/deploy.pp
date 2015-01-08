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
  $source       = undef,
  $war          = undef,

  # Add these var for unit test
  $home         = $jetty::home,
  $user         = $jetty::user,
  $group        = $jetty::group,
) {

  validate_absolute_path($source)
  validate_string($war)
 
  file { "jetty_war_${war}":
    ensure => file,
    path   => "${home}/webapps/${war}",
    owner  => $user,
    group  => $group,
    source => $source,
    notify => Service['jetty'],
  }
}