#
# Cookbook Name:: sagecrm
# Recipe:: default
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#

iis_pool 'CRM App Pool' do
  runtime_version "2.0"
  pipeline_mode :Integrated
  thirty_two_bit true
  action :add
end

iis_site 'Default Web Site' do
  protocol :http
  port 80
  path "C:\\inetpub\\WWWRoot"
  action [:add,:start]
end

iis_app 'CRM' do
  path "/CRM"
  application_pool 'CRM App Pool'
  physical_path "#{node['sagecrm']['instance']['install_dir']}CRM\\WWWRoot"
  enabled_protocols "http"
  action :add
end