puppet-jetty
============

Puppet module for installing Jetty

## Dependencies

This module requires Puppet >= 2.7.14 due to `each` function, need `parser = future` in `puppet.conf`.
See http://docs.puppetlabs.com/references/latest/function.html#each

This module depends on `hiera` which is introduced in Puppet 3.0.
This module depends on `puppetlabs/java` 
This module depends on `pdxcat/singleton`

## Usage
In your hieradata file...

Basic usage:
```yaml
---
jetty::version: 9.1.2.v20140210
```

With more options:
```yaml
---
jetty::version: 9.1.2.v20140210
jetty::java_properties:
    JAVA_HOME: /etc/alternatives/jre
    JAVA: /etc/alternatives/jre/bin/java
    JAVA_OPTIONS: "\"-server -XX:MaxPermSize=256m -Xms256m -Xmx2048m\""
jetty::jetty_properties:
    JETTY_HOME: /opt/jetty
    JETTY_USER: jetty 
    JETTY_PORT: 8080
    JETTY_HOST: 0.0.0.0
    JETTY_LOGS: /var/log/jetty
```

## License

MIT