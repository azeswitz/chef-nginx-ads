#
# Cookbook Name:: ads18f
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
include_recipe 'apt::default'
include_recipe 'selinux::permissive'
include_recipe 'ads18f::firewall'
include_recipe 'ads18f::web_user'
include_recipe 'ads18f::nginx'
