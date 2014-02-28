puppet-jetty
============

Puppet module for installing Jetty

## Dependencies

This module requires Puppet >= 3.0.0 due to `each` function, need `parser = future` in `puppet.conf`.
See http://docs.puppetlabs.com/references/latest/function.html#each

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
jetty::group: jetty
jetty::user: jetty
jetty::home: /opt/jetty
jetty::log: /var/log/jetty
jetty::create_work_dir: true
jetty::remove_demo_base: true

# Add in /etc/default/jetty
jetty::java_properties:
    JAVA_HOME: /etc/alternatives/jre
    JAVA: /etc/alternatives/jre/bin/java
    JAVA_OPTIONS: "\"-server -XX:MaxPermSize=256m -Xms256m -Xmx2048m\""
    ...

# Add in /etc/default/jetty
jetty::jetty_properties:
    JETTY_HOME: /opt/jetty
    JETTY_USER: jetty 
    JETTY_PORT: 8080
    JETTY_HOST: 0.0.0.0
    JETTY_LOGS: /var/log/jetty
    ...
```

More usage:
```puppet
class {'jetty::deploy':
  source => /tmp/myapp.war,
  war => app.war,
}
```


## License

MIT