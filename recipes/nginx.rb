#
# Cookbook Name:: ads18f
# Recipe:: nginx
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe 'nginx::ohai_plugin'

directory '/etc/ssl/nginx' do
  owner  'root'
  group  'root'
  mode   '0755'
  action :create
end

file '/etc/ssl/nginx/nginx-repo.key' do
  owner   'root'
  group   'root'
  mode    '0644'
  content node.attribute['nginx']['nginx_repo_key']
end

file '/etc/ssl/nginx/nginx-repo.crt' do
  owner   'root'
  group   'root'
  mode    '0644'
  content node.attribute['nginx']['nginx_repo_crt']
end

remote_file '/etc/ssl/nginx/CA.crt' do
  source 'https://cs.nginx.com/static/files/CA.crt'
  owner  'root'
  group  'root'
  mode   '0644'
end

remote_file '/etc/apt/apt.conf.d/90nginx' do
  source 'https://cs.nginx.com/static/files/90nginx'
  owner  'root'
  group  'root'
  mode   '0644'
end

#REMOVED - ARZ
#this is currently set up only for ubuntu; rhel to follow
if platform_family?('debian')
  include_recipe 'apt::default'

  apt_repository 'nginx_plus' do
    uri          'https://plus-pkgs.nginx.com/ubuntu'
    distribution node['lsb']['codename']
    components   %w(nginx-plus)
    deb_src      false
    key          'http://nginx.org/keys/nginx_signing.key'
  end
end

package node['nginx']['package_name'] do
  notifies :reload, 'ohai[reload_nginx]', :immediately
  not_if 'which nginx'
end

directory node['nginx']['dir'] do
  owner     'root'
  group     node['root_group']
  mode      '0755'
  recursive true
end

directory node['nginx']['log_dir'] do
  mode      node['nginx']['log_dir_perm']
  owner     node['nginx']['user']
  action    :create
  recursive true
end

directory File.dirname(node['nginx']['pid']) do
  owner     'root'
  group     node['root_group']
  mode      '0755'
  recursive true
end

directory "#{node['nginx']['dir']}/conf.d" do
  owner 'root'
  group node['root_group']
  mode  '0755'
end

service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action   :enable
end

include_recipe 'nginx::commons_script'

template 'nginx.conf' do
  path     "#{node['nginx']['dir']}/nginx.conf"
  source   node['nginx']['conf_template']
  cookbook node['nginx']['conf_cookbook']
  owner    'root'
  group    node['root_group']
  mode     '0644'
  notifies :reload, 'service[nginx]', :delayed
end

if node['nginx']['default_site_enabled'] == 'true'
  template "#{node['nginx']['dir']}/conf.d/default.conf" do
    source   'default-site.erb'
    owner    'root'
    group    node['root_group']
    mode     '0644'
    notifies :reload, 'service[nginx]', :delayed
  end
else
  file "#{node['nginx']['dir']}/conf.d/default.conf" do
    action :delete
  end
end

if node['nginx']['plus_status_enable'] == 'true'
  template 'nginx_plus_status' do
    path   "#{node['nginx']['dir']}/conf.d/nginx_plus_status.conf"
    source 'nginx_plus_status.erb'
    owner  'root'
    group  node['root_group']
    mode   '0644'
    notifies :reload, 'service[nginx]', :delayed
  end
end
