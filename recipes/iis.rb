#
# Cookbook Name:: sagecrm
# Recipe:: default
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#

iis_pool node['sagecrm']['website']['main']['application_pool'] do
  runtime_version '2.0'
  pipeline_mode :Integrated
  action :add
end

iis_pool node['sagecrm']['application']['crm']['application_pool'] do
  runtime_version '2.0'
  pipeline_mode :Integrated
  thirty_two_bit true
  action :add
end

iis_site node['sagecrm']['website']['main']['name'] do
  application_pool node['sagecrm']['website']['main']['application_pool']
  protocol node['sagecrm']['website']['main']['protocol']
  port node['sagecrm']['website']['main']['port']
  path node['sagecrm']['website']['main']['path']
  log_directory node['sagecrm']['website']['main']['log_directory']
  log_period node['sagecrm']['website']['main']['log_period']
  action [:add,:start]
end

iis_app 'CRM' do
  site_name node['sagecrm']['website']['main']['name']
  path node['sagecrm']['application']['crm']['path']
  application_pool node['sagecrm']['application']['crm']['application_pool']
  physical_path node['sagecrm']['application']['crm']['physical_path']
  enabled_protocols node['sagecrm']['application']['crm']['enabled_protocols']
  action :add
end

iis_config "/section:system.webServer/asp /enableParentPaths:\"True\" /commit:apphost" do
  action :set
  notifies :restart, 'windows_service[W3SVC]'
end

iis_config "/section:system.webServer/asp /scriptErrorSentToBrowser:\"True\" /commit:apphost" do
  action :set
  notifies :restart, 'windows_service[W3SVC]'
end

iis_config "/section:anonymousAuthentication /username:\"\" --password" do
  action :set
  notifies :restart, 'windows_service[W3SVC]'
end

iis_config "/section:handlers /accessPolicy:Read,Script,Execute" do
  action :set
  notifies :restart, 'windows_service[W3SVC]'
end

windows_service 'W3SVC' do
  action :nothing
end