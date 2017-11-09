#
# Cookbook Name:: sagecrm
# Recipe:: default
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#

%w(CRMEscalationService CRMIndexerService CRMIntegrationService SageCRMQuickFindService CRMTomcat7).each do |service_name|
  windows_service "Configure startup type for service #{service_name}" do
    service_name service_name
    action :configure_startup
    run_as_user node['sagecrm']['services'][service_name]['run_as_user']
    run_as_password node['sagecrm']['services'][service_name]['run_as_user'].nil? ? nil : node['sagecrm']['services'][service_name]['run_as_password']
    startup_type node['sagecrm']['services'][service_name]['startup']
  end
  
  windows_service "Change running state for service #{service_name}" do
    service_name service_name
    action node['sagecrm']['services'][service_name]['startup'] == :automatic ? :start : :stop
  end
end