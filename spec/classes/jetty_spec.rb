require 'spec_helper'

describe 'jetty' do

  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }

  it { should contain_class('java') }
  #it { should contain_package('unzip') }
  #it { should contain_package('wget') }

  context "with default param" do

    it do
      should contain_group('jetty').with({
        'ensure' => 'present',
      })
    end

    it do
      should contain_user('jetty').with({
        'ensure'     => 'present',
        'groups'     => 'jetty',
        'managehome' => 'true',
        'shell'      => '/bin/bash',
      })
    end

    it do
      should contain_exec('download jetty').with({
        'cwd'     => '/tmp',
        'path'    => '/bin:/usr/bin',
        'command' => 'wget http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/9.1.2.v20140210/jetty-distribution-${version}.zip',
        'creates' => '/tmp/jetty-distribution-9.1.2.v20140210.zip',
        'notify'  => 'Exec[\'unzip jetty\']',
      })
    end

    it do
      should contain_file('jetty directory').with({
        'name'    => '/opt/jetty-distribution-9.1.2.v20140210',
        'ensure'  => 'directory',
        'owner'   => 'jetty',
        'group'   => 'jetty',
        'recurse' => 'true',
      })
    end

  end

  context "with param" do
    let(:params) { {:version =>'9.1.2.v20140210', :group => 'jettygroup', :user => 'jettyuser'} }

    it do
      should contain_group('jettygroup').with({
        'ensure' => 'present',
      })
    end
    
    it do
      should contain_user('jettyuser').with({
        'ensure'     => 'present',
        'groups'     => 'jettygroup',
        'managehome' => 'true',
        'shell'      => '/bin/bash',
      })
    end

  end

end
at_exit { RSpec::Puppet::Coverage.report! }
