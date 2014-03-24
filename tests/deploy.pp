#
# Smoke test.
#
class {'jetty': version => '9.1.3.v20140225'}
class {'jetty::deploy': source => '/tmp/mysource.war', war => 'mywar.war'}