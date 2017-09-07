#
# Cookbook Name:: database-loader
# Recipe:: default
#
# Copyright (c) 2016 ['Jannik Zinkl', 'Tilman Marquart'], All Rights Reserved.
package_selector = node['database-loader']['package_selector']
platform_family = node['platform_family']
platform_version = node['platform_version'][0]

gem_package = package_selector[platform_family][platform_version]

# load the .gem-file to the chef-cache-path
gem_path = Chef::Config['file_cache_path'] + '/' + gem_package
cookbook_file gem_path do
  source gem_package
end

# Install the precompiled mysql2 gem
chef_gem 'mysql2' do
  clear_sources true
  compile_time true
  source Chef::Config['file_cache_path'] + '/cookbooks/database-loader/files/default/' + gem_package
end
