#
# Cookbook Name:: sagecrm
# Recipe:: default
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'iis'

%w(CRMEscalationService CRMIndexerService CRMIntegrationService SageCRMQuickFindService CRMTomcat7).each do |service_name|
  service service_name do
    guard_interpreter :powershell_script
    service_name service_name
    only_if "(get-service | ?{$_.Name -eq '#{service_name}' -and $_.StartType -ne 'Disabled'}).Length -gt 0"
    action :nothing
  end
end

log 'Stop Sage CRM IIS dependancies' do
  level :info
  subscribes :write, 'service[iis]', :before
  notifies :stop, 'service[CRMEscalationService]', :before
  notifies :stop, 'service[CRMIndexerService]', :before
  notifies :stop, 'service[CRMIntegrationService]', :before
  notifies :stop, 'service[SageCRMQuickFindService]', :before
  notifies :stop, 'service[CRMTomcat7]', :before
  action :nothing
end

log 'Start Sage CRM IIS dependancies' do
  level :info
  subscribes :write, 'service[iis]', :immediately
  notifies :start, 'service[CRMTomcat7]', :immediately
  notifies :start, 'service[SageCRMQuickFindService]', :immediately
  notifies :start, 'service[CRMIntegrationService]', :immediately
  notifies :start, 'service[CRMIndexerService]', :immediately
  notifies :start, 'service[CRMEscalationService]', :immediately
  action :nothing
end

template "#{node['sagecrm']['application']['sdata']['physical_path']}\\web.config" do
  source 'web.config.erb'
end

iis_pool node['sagecrm']['website']['main']['application_pool'] do
  username node['sagecrm']['website']['main']['pool_username']
  password node['sagecrm']['website']['main']['pool_password']
  identity_type node['sagecrm']['website']['main']['pool_identity']
  runtime_version '2.0'
  pipeline_mode :Integrated
  action :add
end

iis_pool node['sagecrm']['application']['crm']['application_pool'] do
  username node['sagecrm']['application']['crm']['pool_username']
  password node['sagecrm']['application']['crm']['pool_password']
  identity_type node['sagecrm']['application']['crm']['pool_identity']  
  runtime_version '2.0'
  pipeline_mode :Integrated
  thirty_two_bit true
  action :add
end

iis_pool node['sagecrm']['application']['sdata']['application_pool'] do
  username node['sagecrm']['application']['sdata']['pool_username']
  password node['sagecrm']['application']['sdata']['pool_password']
  identity_type node['sagecrm']['application']['sdata']['pool_identity']    
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

set_permissions_for_crm = "icacls \"#{node['sagecrm']['instance']['install_dir']}\\#{node['sagecrm']['application']['crm']['name']}\" /t /grant \"#{app_pool}\":(OI)(CI)F /Q"
set_permissions_for_services = "icacls \"#{node['sagecrm']['instance']['install_dir']}\\Services\" /t /grant \"#{app_pool}\":(OI)(CI)F /Q"

execute set_permissions_for_crm do
end 

execute set_permissions_for_services do
end 

iis_config "/section:system.webServer/asp /enableParentPaths:\"True\" /commit:apphost" do
  action :set
end

iis_config "/section:system.webServer/asp /scriptErrorSentToBrowser:\"True\" /commit:apphost" do
  action :set
end

iis_config "/section:anonymousAuthentication /username:\"\" --password" do
  action :set
end

iis_config "/section:handlers /accessPolicy:Read,Script,Execute" do
  action :set
end

service 'iis' do
	action :stop
	notifies :stop, 'service[CRMTomcat7]', :before
end

service 'iis' do
	action :start
	notifies :start, 'service[CRMTomcat7]'
end
