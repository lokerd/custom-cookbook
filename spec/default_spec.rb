require 'spec_helper'

describe 'errbit::defaultu' do

  # Specific Ubuntu tests
  #
  context 'on ubuntu' do
    before{ Fauxhai.mock(platform:'ubuntu') }
    let(:runner){
      ChefSpec::ChefRunner.new(
        :cookbook_path => '/Users/dpaulus/Code/errbit_chef/cookbooks'
      ).converge('errbit::default')
    }

    it 'should install the correct packages' do
      runner.should install_package 'libcurl4-gnutls-dev'
    end
  end

  # Specific CentOS tests
  #
  #context 'on centos' do
  #  before{ Fauxhai.mock(platform:'centos') }
  #  let(:runner){
  #    ChefSpec::ChefRunner.new(
  #      :cookbook_path => '/Users/dpaulus/Code/errbit_chef/cookbooks')
  #    .converge('errbit::default')
  #  }
  #end

  # Default testing for all OS versions
  #
  let(:runner){
    ChefSpec::ChefRunner.new(
      :cookbook_path => '/Users/dpaulus/Code/errbit_chef/cookbooks')
    .converge('errbit::default')
  }

  it 'should install the correct packages' do
    runner.should install_package 'git'
    runner.should install_package 'apache2'
    runner.should install_package 'mongodb-10gen'
  end

  it 'should create the deployment directories' do
    runner.should create_directory '/home/deployer/errbit'
    runner.should create_directory '/home/deployer/errbit/shared'
    runner.should create_directory '/home/deployer/errbit/shared/log'
    runner.should create_directory '/home/deployer/errbit/shared/pids'
    runner.should create_directory '/home/deployer/errbit/shared/system'
    runner.should create_directory '/home/deployer/errbit/shared/tmp'
    runner.should create_directory '/home/deployer/errbit/shared/vendor_bundle'
    runner.should create_directory '/home/deployer/errbit/shared/scripts'
    runner.should create_directory '/home/deployer/errbit/shared/config'
    runner.should create_directory '/home/deployer/errbit/shared/sockets'
  end

  it 'should create the config files' do
    runner.should create_file '/home/deployer/errbit/shared/config/config.yml'
    runner.should create_file '/home/deployer/errbit/shared/config/mongoid.yml'
  end

end
