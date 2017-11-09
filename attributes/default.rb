#
# Author:: Taliesin Sisson (<taliesins@yahoo.com>)
# Cookbook Name:: sagecrm
# Attributes:: default
# Copyright 2014-2015, Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


default['sagecrm']['name'] = 'Sage CRM'
default['sagecrm']['filename'] = 'SageCrm7.2a.1'
default['sagecrm']['filenameextension'] = 'zip'
default['sagecrm']['url'] = 'http://www.yourserver.com/' + default['sagecrm']['filename'] + '.' + default['sagecrm']['filenameextension'] 
default['sagecrm']['checksum'] = '677b2d0d6dabbd8a0bb5977d50532379166f2f03b8da28853257786a4e41669c'
default['sagecrm']['home'] = "#{Chef::Config['file_cache_path']}/#{node['sagecrm']['filename']}/#{node['sagecrm']['checksum']}"

default['sagecrm']['service']['account'] = '.\SageCRM' # e.g. SageCRM. This account is used to access the database server, so ensure that database permission have been configured. This account is used to run service, so ensure that it has the correct permissions on each node. If using multiple nodes, active directory is required.
default['sagecrm']['service']['password'] = 'P@ssw0rd' # e.g. P@ssw0rd. This is the password to use if creating a windows account locally to use.
default['sagecrm']['service']['group'] = 'Administrators'

default['sagecrm']['installaccount']['account'] = node['sagecrm']['service']['account']
default['sagecrm']['installaccount']['password'] = node['sagecrm']['service']['password']

username = node['sagecrm']['service']['account']
domain = ""

if username.include? '\\'
	domain = username.split('\\')[0]
	username = username.split('\\')[1]
end

if username.include? '@'
	domain = username.split('@')[1]
	username = username.split('@')[0]
end

if domain == ""  || domain == "."
	domain = node["hostname"]
end

default['sagecrm']['database']['sys_roles'] = {:sysadmin => :ADD}
default['sagecrm']['database']['host'] = '127.0.0.1'
default['sagecrm']['database']['port'] = node['sql_server']['port']
default['sagecrm']['database']['username'] = nil
default['sagecrm']['database']['password'] = nil
default['sagecrm']['database']['initial_size'] = 512
default['sagecrm']['database']['database_name'] = 'CRM'
default['sagecrm']['database']['account'] = "#{domain}\\#{username}"

default['sagecrm']['instance']['FarmDns'] = node['fqdn']  # e.g. servicebus.localtest.me
default['sagecrm']['instance']['FarmCertificateThumbprint'] = '' # if sagecrm::certificate is called it will populate this field e.g. wildcard certificate *.localtest.me thumbprint 
default['sagecrm']['instance']['install_dir'] = 'C:\\Program Files (x86)\\Sage\\CRM\\'

default['sagecrm']['certificate']['CaCertificate']['common_name'] = node['sagecrm']['instance']['FarmDns'] + '.ca'
default['sagecrm']['certificate']['CaCertificate']['key_source'] = 'self-signed'
default['sagecrm']['certificate']['CaCertificate']['pkcs12_path'] = File.join(Chef::Config[:file_cache_path], node['sagecrm']['certificate']['CaCertificate']['common_name'] + '.pfx')
default['sagecrm']['certificate']['CaCertificate']['pkcs12_passphrase'] = nil
default['sagecrm']['certificate']['CaCertificate']['private_key_acl'] = ["#{domain}\\#{username}", "#{domain}\\vagrant"]
default['sagecrm']['certificate']['CaCertificate']['store_name'] = "ROOT"
default['sagecrm']['certificate']['CaCertificate']['user_store'] = false
default['sagecrm']['certificate']['CaCertificate']['cert_path'] = File.join(Chef::Config[:file_cache_path], node['sagecrm']['certificate']['CaCertificate']['common_name'] + '.pem')
default['sagecrm']['certificate']['CaCertificate']['key_path'] = File.join(Chef::Config[:file_cache_path], node['sagecrm']['certificate']['CaCertificate']['common_name'] + '.key')

default['sagecrm']['certificate']['FarmCertificate']['common_name'] = node['sagecrm']['instance']['FarmDns']
default['sagecrm']['certificate']['FarmCertificate']['cert_source'] = 'with_ca'
default['sagecrm']['certificate']['FarmCertificate']['pkcs12_path'] = File.join(Chef::Config[:file_cache_path], node['sagecrm']['certificate']['FarmCertificate']['common_name'] + '.pfx')
default['sagecrm']['certificate']['FarmCertificate']['pkcs12_passphrase'] = nil
default['sagecrm']['certificate']['FarmCertificate']['private_key_acl'] = ["#{domain}\\#{username}", "#{domain}\\vagrant"]
default['sagecrm']['certificate']['FarmCertificate']['store_name'] = "MY"
default['sagecrm']['certificate']['FarmCertificate']['user_store'] = false
default['sagecrm']['certificate']['FarmCertificate']['ca_cert_path'] = node['sagecrm']['certificate']['CaCertificate']['cert_path']
default['sagecrm']['certificate']['FarmCertificate']['ca_key_path'] = node['sagecrm']['certificate']['CaCertificate']['key_path']

default['sagecrm']['windows_features'] = ['IIS-WebServerRole', 'IIS-WebServer', 'IIS-CommonHttpFeatures', 'IIS-HttpErrors', 'IIS-ApplicationDevelopment', 'IIS-RequestFiltering', 'IIS-NetFxExtensibility', 'IIS-HealthAndDiagnostics', 'IIS-HttpLogging', 'IIS-Security', 'IIS-RequestMonitor', 'IIS-Performance', 'NetFx3', 'NetFx3ServerFeatures', 'IIS-StaticContent', 'IIS-DefaultDocument', 'IIS-WebSockets', 'IIS-WebServerManagementTools', 'IIS-ManagementConsole', 'IIS-ManagementService', 'IIS-IIS6ManagementCompatibility','IIS-Metabase', 'IIS-ISAPIExtensions', 'IIS-ISAPIFilter', 'IIS-StaticContent', 'IIS-DefaultDocument', 'IIS-DirectoryBrowsing', 'IIS-ASPNET', 'IIS-ASP', 'IIS-CGI', 'IIS-ServerSideIncludes', 'IIS-BasicAuthentication', 'IIS-HttpCompressionStatic', 'IIS-ManagementConsole', 'IIS-WMICompatibility', 'IIS-LegacyScripts', 'IIS-LegacySnapIn', 'SNMP','Printing-XPSServices-Features', 'IIS-WindowsAuthentication']

#The sql login credentials for the account to manage and run Sage Crm
default['sagecrm']['properties']['User'] = username
default['sagecrm']['properties']['Password'] = node['sagecrm']['service']['password']

default['sagecrm']['properties']['License']['Name'] = ''
default['sagecrm']['properties']['License']['Company'] = ''
default['sagecrm']['properties']['License']['Serial'] = ''
default['sagecrm']['properties']['Currency'] = 'Euro'

default['sagecrm']['properties']['Country'] = 'United Kingdom'
default['sagecrm']['properties']['AreaCode'] = '+44'
default['sagecrm']['properties']['OutNumber'] = '00'

default['sagecrm']['properties']['ProxyServer'] = ''
default['sagecrm']['properties']['ProxyUser'] = ''
default['sagecrm']['properties']['ProxyPassword'] = ''
default['sagecrm']['properties']['ProxyDomain'] = ''
default['sagecrm']['properties']['ProxyPort'] = ''

default['sagecrm']['properties']['UseHttps'] = false
default['sagecrm']['properties']['UseProxy'] = false

default['sagecrm']['properties']['Registration']['CompanyContact'] = 'Contact Name'
default['sagecrm']['properties']['Registration']['CompanyEmail'] = 'ContactName@CompanyName.com'
default['sagecrm']['properties']['Registration']['CompanyPhone'] = '+44000000'
default['sagecrm']['properties']['Registration']['BPName'] = 'BP Company Name'
default['sagecrm']['properties']['Registration']['BPContact'] = 'BP Contact Name'
default['sagecrm']['properties']['Registration']['BPEmail'] = 'BPContactName@BPCompanyName.com'
default['sagecrm']['properties']['Registration']['BPPhone'] = '+44111111'

default['sagecrm']['website']['main']['name'] = 'Default Web Site'
default['sagecrm']['website']['main']['application_pool'] = 'DefaultAppPool'
default['sagecrm']['website']['main']['pool_identity'] = :ApplicationPoolIdentity
default['sagecrm']['website']['main']['pool_username'] = ''
default['sagecrm']['website']['main']['pool_password'] = ''
default['sagecrm']['website']['main']['path'] = 'C:\inetpub\wwwroot'
default['sagecrm']['website']['main']['log_directory'] = 'C:\inetpub\logs'
default['sagecrm']['website']['main']['log_period'] = :Monthly
default['sagecrm']['website']['main']['port'] = 80
default['sagecrm']['website']['main']['protocol'] = :http

default['sagecrm']['application']['crm']['name'] = 'CRM'
default['sagecrm']['application']['crm']['application_pool'] = 'CRM App Pool'
default['sagecrm']['application']['crm']['pool_identity'] = :ApplicationPoolIdentity
default['sagecrm']['application']['crm']['pool_username'] = ''
default['sagecrm']['application']['crm']['pool_password'] = ''
default['sagecrm']['application']['crm']['path'] = '/CRM'
default['sagecrm']['application']['crm']['physical_path'] = "#{node['sagecrm']['instance']['install_dir']}#{node['sagecrm']['application']['crm']['name']}\\WWWRoot"
default['sagecrm']['application']['crm']['enabled_protocols'] = 'http'

default['sagecrm']['application']['sdata']['name'] = 'sdata'
default['sagecrm']['application']['sdata']['application_pool'] = 'CRMRewriter App Pool'
default['sagecrm']['application']['sdata']['pool_identity'] = :ApplicationPoolIdentity
default['sagecrm']['application']['sdata']['pool_username'] = ''
default['sagecrm']['application']['sdata']['pool_password'] = ''
default['sagecrm']['application']['sdata']['path'] = '/sdata'
default['sagecrm']['application']['sdata']['physical_path'] = "#{node['sagecrm']['instance']['install_dir']}Services\\IISUtils\\CRMRewriter"
default['sagecrm']['application']['sdata']['enabled_protocols'] = 'http'

default['sagecrm']['services']['CRMEscalationService']['startup'] = :manual
default['sagecrm']['services']['CRMEscalationService']['run_as_user'] = node['sagecrm']['service']['account']
default['sagecrm']['services']['CRMEscalationService']['run_as_password'] = node['sagecrm']['service']['password']

default['sagecrm']['services']['CRMIndexerService']['startup'] = :automatic
default['sagecrm']['services']['CRMIndexerService']['run_as_user'] = node['sagecrm']['service']['account']
default['sagecrm']['services']['CRMIndexerService']['run_as_password'] = node['sagecrm']['service']['password']

default['sagecrm']['services']['CRMIntegrationService']['startup'] = :manual
default['sagecrm']['services']['CRMIntegrationService']['run_as_user'] = node['sagecrm']['service']['account']
default['sagecrm']['services']['CRMIntegrationService']['run_as_password'] = node['sagecrm']['service']['password']

default['sagecrm']['services']['SageCRMQuickFindService']['startup'] = :automatic
default['sagecrm']['services']['SageCRMQuickFindService']['run_as_user'] = node['sagecrm']['service']['account']
default['sagecrm']['services']['SageCRMQuickFindService']['run_as_password'] = node['sagecrm']['service']['password']

default['sagecrm']['services']['CRMTomcat7']['startup'] = :automatic
default['sagecrm']['services']['CRMTomcat7']['run_as_user'] = node['sagecrm']['service']['account']
default['sagecrm']['services']['CRMTomcat7']['run_as_password'] = node['sagecrm']['service']['password']