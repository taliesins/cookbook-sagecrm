#
# Cookbook Name:: sagecrm
# Recipe:: default
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#


if node['sagecrm']['service']['account'] == ""
    raise "Please configure Sage CRM service_account attribute is configured"
end

if node['sagecrm']['service']['password'] == ""
    raise "Please configure Sage CRM service_account_password attribute is configured"
end

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

user username do
	action :create
	password node['sagecrm']['service']['password']
	only_if { domain == node["hostname"] }
end

group node['sagecrm']['service']['group'] do
	action :modify
	members domain + '\\' + username
	append true
end