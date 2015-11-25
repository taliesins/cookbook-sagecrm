#
# Cookbook Name:: sagecrm
# Recipe:: default
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#

if node['sagecrm']['database']['account'] == ""
    raise "Please configure Sage CRM database account attribute is configured"
end

sql_server_connection_info = {
  :host     => node['sagecrm']['database']['host'],
  :port     => node['sagecrm']['database']['port'],
  :username => node['sagecrm']['database']['username'],
  :password => node['sagecrm']['database']['password']
}

sql_server_database_user node['sagecrm']['database']['account'] do
  connection sql_server_connection_info
  sql_sys_roles node['sagecrm']['database']['sys_roles']
  windows_user true
  action :create
end

sql_server_database_user node['sagecrm']['properties']['User'] do
  connection sql_server_connection_info
  sql_sys_roles node['sagecrm']['database']['sys_roles']
  windows_user false
  password node['sagecrm']['properties']['Password']
  action :create
end
