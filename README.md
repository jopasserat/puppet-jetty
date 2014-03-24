puppet-jetty
============

Puppet module for installing and configuring Jetty

## Dependencies

This module requires Puppet >= 3.0.0 due to [each](http://docs.puppetlabs.com/references/latest/function.html#each) function, need `parser = future` in `puppet.conf`.<br />

### Basic usage:

In your puppet file

```puppet
include jetty
```

In your hieradata file

```yaml
---
jetty::version: 9.1.3.v20140225
```

It will create `/etc/default/jetty` with these default values:

```text
JETTY_USER=jetty
JETTY_HOME=/opt/jetty
JETTY_HOST=127.0.0.1
JETTY_PORT=8080
JETTY_LOGS=/var/log/jetty
```

## Parameters

  * `jetty::version`: version of Jetty (required)
  * `jetty::group`: group running Jetty, default `jetty`
  * `jetty::user`: user running Jetty, default `jetty`
  * `jetty::home`: Jetty home directory, default `/opt/jetty`
  * `jetty::log`: Jetty log directory, default `/var/log/jetty`
  * `jetty::create_work_dir`: If `work` directory must be created, default `false`
  * `jetty::remove_demo_base`: If the demo app must be removed, default `true`

Values of `jetty::user`, `jetty::home` and `jetty::log` are automatically add to `/etc/default/jetty`


### Override Jetty properties

All JETTY_* properties can be added in your hieradata file

```yaml
---
# Merged with default values and added in /etc/default/jetty
jetty::jetty_properties:
    JETTY_PORT: 9090
    JETTY_HOST: 0.0.0.0
    ...
```

### Add Java properties

All JAVA* properties can be added in your hieradata file

```yaml
---
# Added in /etc/default/jetty
jetty::java_properties:
    JAVA_HOME: /etc/alternatives/jre
    JAVA: /etc/alternatives/jre/bin/java
    JAVA_OPTIONS: "\"-server -XX:MaxPermSize=256m -Xms256m -Xmx2048m\""
    ...
```

### Deploy war

in your hieradata file

```yaml
---
jetty::deploy::source: /tmp/myapp.war
jetty::deploy::war: app.war
```

or basic puppet usage

```puppet
class {'jetty::deploy':
  source => /tmp/myapp.war,
  war => app.war,
}
```

## Tests

### Unit tests

```bash
$ rake test
```

### Smoke tests

```bash
$ puppet apply tests/init.pp --noop
$ puppet apply tests/deploy.pp --noop
```

## Authors

Gamaliel Sick

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