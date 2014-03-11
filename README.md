puppet-jetty
============

Puppet module for installing Jetty

## Dependencies

This module requires Puppet >= 3.0.0 due to [each](http://docs.puppetlabs.com/references/latest/function.html#each) function, need `parser = future` in `puppet.conf`.<br />

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

# Added in /etc/default/jetty
jetty::java_properties:
    JAVA_HOME: /etc/alternatives/jre
    JAVA: /etc/alternatives/jre/bin/java
    JAVA_OPTIONS: "\"-server -XX:MaxPermSize=256m -Xms256m -Xmx2048m\""
    ...

# Added in /etc/default/jetty
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

```
The MIT License (MIT)

Copyright (c) 2014 gsick

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```