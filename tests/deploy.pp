#
# Smoke test.
#
class {'jetty': version => '9.1.4.v20140401'}
class {'jetty::deploy': source => '/tmp/mysource.war', war => 'mywar.war'}