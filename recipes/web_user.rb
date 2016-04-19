#
# Cookbook Name:: ads18f
# Recipe:: web_user
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
group node['ads18f']['group']

user node['ads18f']['user'] do
  group node['ads18f']['group']
  system true
  shell '/bin/bash'
end
