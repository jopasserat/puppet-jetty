require 'spec_helper'

describe 'jetty' do

  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }

  it { should contain_class('java') }
  it { should contain_package('java') }

  it { should contain_class('singleton') }
  it { should contain_package('singleton_package_unzip') }
  it { should contain_package('singleton_package_wget') }

  #it { should contain_package('unzip') }
  #it { should contain_package('wget') }

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
        'shell'      => '/bin/bash',
        'require'    => 'Group[jetty group]',
      })
    end

    it do
      should contain_exec('download jetty').with({
        'cwd'     => '/tmp',
        'path'    => '/bin:/usr/bin',
        'command' => 'wget http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.1.3.v20140225/jetty-distribution-9.1.3.v20140225.zip',
        'creates' => '/tmp/jetty-distribution-9.1.3.v20140225.zip',
        'notify'  => 'Exec[unzip jetty]',
        'require' => 'Package[wget]',
      })
    end

    it do
      should contain_exec('unzip jetty').with({
        'cwd'     => '/tmp',
        'path'    => '/bin:/usr/bin',
        'command' => 'unzip jetty-distribution-9.1.3.v20140225.zip -d /opt',
        'creates' => '/opt/jetty-distribution-9.1.3.v20140225',
        'require' => 'Package[unzip]',
      })
    end

    it do
      should contain_file('jetty directory').with({
        'path'    => '/opt/jetty-distribution-9.1.3.v20140225',
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
        'target'  => '/opt/jetty-distribution-9.1.3.v20140225',
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
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
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

  end

  context "with java properties param" do
    let(:params) { {:java_properties => {'JAVA_HOME' => '/etc/alternatives/jre'}} }

  end

end
at_exit { RSpec::Puppet::Coverage.report! }
