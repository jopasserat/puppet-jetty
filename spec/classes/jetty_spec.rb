require 'spec_helper'

describe 'jetty' do

  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  let(:parser) { 'future' }

  it { should contain_class('java') }
  it { should contain_package('java') }

  context "with default param" do

    it do
      should contain_group('jetty group').with({
        'name'   => 'jetty',
        'ensure' => 'present',
      })
    end

    it do
      should contain_user('jetty user').with({
        'name'       => 'jetty',
        'ensure'     => 'present',
        'groups'     => 'jetty',
        'managehome' => 'true',
        'shell'      => '/sbin/nologin',
        'system'     => 'true',
        'require'    => 'Group[jetty group]',
      })
    end

    it do
      should contain_exec('download jetty').with({
        'cwd'     => '/tmp',
        'path'    => '/sbin:/bin:/usr/bin',
        'command' => 'wget http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.1.4.v20140401/jetty-distribution-9.1.4.v20140401.zip',
        'creates' => '/tmp/jetty-distribution-9.1.4.v20140401.zip',
        'notify'  => 'Exec[unzip jetty]',
        'require' => 'Package[wget]',
      })
    end

    it do
      should contain_exec('unzip jetty').with({
        'cwd'     => '/tmp',
        'path'    => '/sbin:/bin:/usr/bin',
        'command' => 'unzip jetty-distribution-9.1.4.v20140401.zip -d /opt',
        'creates' => '/opt/jetty-distribution-9.1.4.v20140401',
        'require' => 'Package[unzip]',
      })
    end

    it do
      should contain_file('jetty directory').with({
        'path'    => '/opt/jetty-distribution-9.1.4.v20140401',
        'ensure'  => 'directory',
        'owner'   => 'jetty',
        'group'   => 'jetty',
        'recurse' => 'true',
        'require' => ['User[jetty user]', 'Exec[unzip jetty]'],
      })
    end

    it do
      should contain_file('jetty home').with({
        'path'    => '/opt/jetty',
        'ensure'  => 'link',
        'target'  => '/opt/jetty-distribution-9.1.4.v20140401',
        'require' => 'File[jetty directory]',
      })
    end

    it do
      should contain_file('jetty init').with({
        'path'    => '/etc/init.d/jetty',
        'ensure'  => 'link',
        'target'  => '/opt/jetty/bin/jetty.sh',
        'require' => 'File[jetty home]',
      })
    end

    it do
      should contain_file('jetty log').with({
        'path'    => '/var/log/jetty',
        'ensure'  => 'directory',
        'owner'   => 'jetty',
        'group'   => 'jetty',
        'recurse' => 'true',
        'require' => 'User[jetty user]',
      })
    end

    it do
      should contain_service('jetty').with({
        'name'       => 'jetty',
        'enable'     => 'true',
        'ensure'     => 'running',
        'hasrestart' => 'true',
        'hasstatus'  => 'false',
        'require'    => 'File[jetty init]',
      })
    end

    it do
      should contain_file('jetty default').with({
        'path'    => '/etc/default/jetty',
        'ensure'  => 'file',
        'owner'   => 'root',
        'group'   => 'root',
      })
    end

    it do
      should contain_file_line('jetty_properties_JETTY_HOME').with({
        'path'    => '/etc/default/jetty',
        'line'    => 'JETTY_HOME=/opt/jetty',
        'match'   => '^(JETTY_HOME=).*$',
        'require' => 'File[jetty default]',
        'notify'  => 'Service[jetty]',
      })
    end

    it do
      should contain_file_line('jetty_properties_JETTY_USER').with({
        'path'    => '/etc/default/jetty',
        'line'    => 'JETTY_USER=jetty',
        'match'   => '^(JETTY_USER=).*$',
        'require' => 'File[jetty default]',
        'notify'  => 'Service[jetty]',
      })
    end

    it do
      should contain_file_line('jetty_properties_JETTY_PORT').with({
        'path'    => '/etc/default/jetty',
        'line'    => 'JETTY_PORT=8080',
        'match'   => '^(JETTY_PORT=).*$',
        'require' => 'File[jetty default]',
        'notify'  => 'Service[jetty]',
      })
    end

    it do
      should contain_file_line('jetty_properties_JETTY_HOST').with({
        'path'    => '/etc/default/jetty',
        'line'    => 'JETTY_HOST=127.0.0.1',
        'match'   => '^(JETTY_HOST=).*$',
        'require' => 'File[jetty default]',
        'notify'  => 'Service[jetty]',
      })
    end

    it do
      should contain_file_line('jetty_properties_JETTY_LOGS').with({
        'path'    => '/etc/default/jetty',
        'line'    => 'JETTY_LOGS=/var/log/jetty',
        'match'   => '^(JETTY_LOGS=).*$',
        'require' => 'File[jetty default]',
        'notify'  => 'Service[jetty]',
      })
    end

    it do
      should_not contain_file('jetty work')
    end

    it do
      should contain_file('jetty demo').with({
        'path'    => '/opt/jetty/demo-base',
        'ensure'  => 'absent',
        'force'   => 'true',
        'require' => 'File[jetty home]',
      })
    end

  end

  context "with create_work_dir param" do
    let(:params) { {:create_work_dir => true} }

    it do
      should contain_file('jetty work').with({
        'path'    => '/opt/jetty/work',
        'ensure'  => 'directory',
        'owner'   => 'jetty',
        'group'   => 'jetty',
        'require' => ['User[jetty user]', 'File[jetty home]'],
      })
    end

  end

  context "with remove_demo_base param" do
    let(:params) { {:remove_demo_base => false} }

    it do
      should_not contain_file('jetty demo')
    end

  end

  context "with jetty properties param" do
    let(:params) { {:jetty_properties => {'JETTY_PORT' => 9090, 'JETTY_HOST' => '0.0.0.0'}} }

    it do
      should contain_file_line('jetty_properties_JETTY_PORT').with({
        'path'    => '/etc/default/jetty',
        'line'    => 'JETTY_PORT=9090',
        'match'   => '^(JETTY_PORT=).*$',
        'require' => 'File[jetty default]',
        'notify'  => 'Service[jetty]',
      })
    end

    it do
      should contain_file_line('jetty_properties_JETTY_HOST').with({
        'path'    => '/etc/default/jetty',
        'line'    => 'JETTY_HOST=0.0.0.0',
        'match'   => '^(JETTY_HOST=).*$',
        'require' => 'File[jetty default]',
        'notify'  => 'Service[jetty]',
      })
    end

  end

  context "with java properties param" do
    let(:params) { {:java_properties => {'JAVA_HOME' => '/etc/alternatives/jre'}} }

    it do
      should contain_file_line('java_properties_JAVA_HOME').with({
        'path'    => '/etc/default/jetty',
        'line'    => 'JAVA_HOME=/etc/alternatives/jre',
        'match'   => '^(JAVA_HOME=).*$',
        'require' => 'File[jetty default]',
        'notify'  => 'Service[jetty]',
      })
    end

  end

end
