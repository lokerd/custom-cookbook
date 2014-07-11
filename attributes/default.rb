#
# Cookbook Name:: errbit
# Attribute:: default
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

default['errbit']['name'] 			= 'errbit'
default['errbit']['user'] 			= 'deployer'
default['errbit']['password'] 		= '$1$qqO27xay$dtmwY9NMmJiSa47xhUZm0.' #errbit
default['errbit']['group'] 			= node['errbit']['user']
default['errbit']['deploy_to'] 		= "/home/#{default['errbit']['user']}/#{node['errbit']['name']}"
default['errbit']['repo_url'] 		= 'git://github.com/errbit/errbit.git'
default['errbit']['revision'] 		= 'master'
default['errbit']['environment'] 	= 'production'

# errbit config.yml
default['errbit']['config']['host'] 								= 'errbit.example.com'
default['errbit']['config']['enforce_ssl'] 							= false
default['errbit']['config']['email_from'] 							= 'errbit@example.com'
default['errbit']['config']['per_app_email_at_notices'] 			= false
default['errbit']['config']['email_at_notices'] 					= [1, 10, 100]
default['errbit']['config']['confirm_resolve_err'] 					= true
default['errbit']['config']['user_has_username'] 					= false
default['errbit']['config']['allow_comments_with_issue_tracker'] 	= true
default['errbit']['config']['use_gravatar'] 						= true
default['errbit']['config']['gravatar_default'] 					= 'identicon'

# mongodb creds
default['errbit']['db']['host'] 	= 'localhost'
default['errbit']['db']['port'] 	= '27017'
default['errbit']['db']['database'] = 'errbit'
default['errbit']['db']['username'] = 'errbit'
default['errbit']['db']['password'] = 'errbit'
