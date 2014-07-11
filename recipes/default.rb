#
# Cookbook Name:: errbit
# Recipe:: default
#
# Copyright 2013, Daniel Paulus
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# build tools
include_recipe 'build-essential::default'

# apache
include_recipe 'apache2::default'
apache_module 'headers' do
  enable true
end

# Passenger
include_recipe 'passenger_apache2::default'

# git
include_recipe 'git'

# mongodb
include_recipe 'mongodb::default'

# user
group node['errbit']['group']
user node['errbit']['user'] do
  action :create
  comment 'Deploy user'
  gid node['errbit']['group']
  shell '/bin/bash'
  home "/home/#{node['errbit']['user']}"
  password node['errbit']['password']
  supports :manage_home => true
  system true
end

# packages
%w(libxml2-dev libxslt1-dev).each do |pkg|
    package pkg do
        action ( :install )
    end
end

# folders
directory node['errbit']['deploy_to'] do
  owner node['errbit']['user']
  group node['errbit']['group']
  mode 00755
  action :create
  recursive true
end

directory "#{node['errbit']['deploy_to']}/shared" do
  owner node['errbit']['user']
  group node['errbit']['group']
  mode 00755
end

%w{ log pids system tmp vendor_bundle scripts config sockets }.each do |dir|
  directory "#{node['errbit']['deploy_to']}/shared/#{dir}" do
    owner node['errbit']['user']
    group node['errbit']['group']
    mode 0775
    recursive true
  end
end

# install the app config
template "#{node['errbit']['deploy_to']}/shared/config/config.yml" do
  source 'config.yml.erb'
  owner node['errbit']['user']
  group node['errbit']['group']
  mode 00644
end

template "#{node['errbit']['deploy_to']}/shared/config/mongoid.yml" do
  source 'mongoid.yml.erb'
  owner node['errbit']['user']
  group node['errbit']['group']
  mode 00644
end

# deploy the application
deploy_revision node['errbit']['deploy_to'] do
  repo node['errbit']['repo_url']
  revision node['errbit']['revision']
  user node['errbit']['user']
  group node['errbit']['group']
  enable_submodules false
  migrate false
  before_migrate do

    directory "#{release_path}/vendor/bundle" do
        mode 00644
        action :create
        recursive true
    end

    link "#{release_path}/vendor/bundle" do
      to "#{node['errbit']['deploy_to']}/shared/vendor_bundle"
    end
    common_groups = %w{development test cucumber staging production}
    execute "bundle install --deployment --without #{(common_groups - ([node['errbit']['environment']])).join(' ')}" do
      ignore_failure true
      cwd release_path
    end
  end

  symlink_before_migrate nil
  symlinks(
    'config/config.yml' => 'config/config.yml',
    'config/mongoid.yml' => 'config/mongoid.yml'
  )
  environment 'RAILS_ENV' => node['errbit']['environment']
  shallow_clone true
  action :deploy #:deploy or :rollback or :force_deploy

  before_restart do
    Chef::Log.info '*' * 20 + 'COMPILING ASSETS' + '*' * 20
    execute 'asset_precompile' do
      cwd release_path
      user node['errbit']['user']
      group node['errbit']['group']
      command 'bundle exec rake assets:precompile --trace'
      environment ({'RAILS_ENV' => node['errbit']['environment']})
    end
  end
  scm_provider Chef::Provider::Git
end

web_app node['errbit']['name'] do
  cookbook         'apache2'
  port             '443'
  server_name      "#{node['errbit']['name']}.digidentity.eu"
  server_aliases   [node['fqdn'], node['hostname']]
  docroot          "#{node['errbit']['deploy_to']}/current/public"
  allow_override   ['all']
  options          ['-MultiViews']
end

template "#{node['errbit']['deploy_to']}/current/config/initializers/secret_token.rb" do
  source 'secret_token.rb.erb'
  owner node['errbit']['user']
  group node['errbit']['group']
  mode 00644
end
