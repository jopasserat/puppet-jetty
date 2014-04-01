require 'spec_helper'

describe 'jetty::deploy' do

  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  let(:parser) { 'future' }

  context "with default param" do
    let(:params) { {:source => '/tmp/mywar.war',
                    :war    => 'myapp.war',
                    :home   => '/opt/jetty',
                    :user   => 'jetty',
                    :group  => 'jetty'} }

    it do
      should contain_file('jetty_war_myapp.war').with({
        'path'    => '/opt/jetty/webapps/myapp.war',
        'ensure'  => 'file',
        'owner'   => 'jetty',
        'group'   => 'jetty',
        'source'  => '/tmp/mywar.war',
        'notify'  => 'Service[jetty]',
      })
    end

  end

end
