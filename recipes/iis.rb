#
# Cookbook Name:: sagecrm
# Recipe:: default
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#

template "#{node['sagecrm']['application']['sdata']['physical_path']}\\web.config" do
  source 'web.config.erb'
end

iis_pool node['sagecrm']['website']['main']['application_pool'] do
  pool_username node['sagecrm']['website']['main']['pool_username']
  pool_password node['sagecrm']['website']['main']['pool_password']
  pool_identity node['sagecrm']['website']['main']['pool_identity']
  runtime_version '2.0'
  pipeline_mode :Integrated
  action :add
end

iis_pool node['sagecrm']['application']['crm']['application_pool'] do
  pool_username node['sagecrm']['application']['crm']['pool_username']
  pool_password node['sagecrm']['application']['crm']['pool_password']
  pool_identity node['sagecrm']['application']['crm']['pool_identity']  
  runtime_version '2.0'
  pipeline_mode :Integrated
  thirty_two_bit true
  action :add
end

iis_pool node['sagecrm']['application']['sdata']['application_pool'] do
  pool_username node['sagecrm']['application']['sdata']['pool_username']
  pool_password node['sagecrm']['application']['sdata']['pool_password']
  pool_identity node['sagecrm']['application']['sdata']['pool_identity']    
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

iis_app node['sagecrm']['application']['crm']['name'] do
  site_name node['sagecrm']['website']['main']['name']
  path node['sagecrm']['application']['crm']['path']
  application_pool node['sagecrm']['application']['crm']['application_pool']
  physical_path node['sagecrm']['application']['crm']['physical_path']
  enabled_protocols node['sagecrm']['application']['crm']['enabled_protocols']
  action :add
end

iis_app node['sagecrm']['application']['sdata']['name'] do
  site_name node['sagecrm']['website']['main']['name']
  path node['sagecrm']['application']['sdata']['path']
  application_pool node['sagecrm']['application']['sdata']['application_pool']
  physical_path node['sagecrm']['application']['sdata']['physical_path']
  enabled_protocols node['sagecrm']['application']['sdata']['enabled_protocols']
  action :add
end

if node['sagecrm']['application']['sdata']['pool_identity'] == :ApplicationPoolIdentity
  app_pool = "IIS AppPool\\#{node['sagecrm']['application']['crm']['application_pool']}"
else
  app_pool = node['sagecrm']['application']['sdata']['pool_username']
end

set_permissions_for_crm = "icacls \"#{node['sagecrm']['instance']['install_dir']}\\#{node['sagecrm']['application']['crm']['name']}\" /t /grant \"#{app_pool}\":(OI)(CI)F"
set_permissions_for_services = "icacls \"#{node['sagecrm']['instance']['install_dir']}\\Services\" /t /grant \"#{app_pool}\":(OI)(CI)F"

execute set_permissions_for_crm do
end 

execute set_permissions_for_services do
end 

iis_config "/section:system.webServer/asp /enableParentPaths:\"True\" /commit:apphost" do
  action :set
  notifies :run, 'execute[IISRESET]'
end

iis_config "/section:system.webServer/asp /scriptErrorSentToBrowser:\"True\" /commit:apphost" do
  action :set
  notifies :run, 'execute[IISRESET]'
end

iis_config "/section:anonymousAuthentication /username:\"\" --password" do
  action :set
  notifies :run, 'execute[IISRESET]'
end

iis_config "/section:handlers /accessPolicy:Read,Script,Execute" do
  action :set
  notifies :run, 'execute[IISRESET]'
end

execute 'IISRESET' do
  action :nothing
end