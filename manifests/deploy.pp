
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