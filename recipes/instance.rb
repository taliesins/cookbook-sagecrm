#
# Cookbook Name:: sagecrm
# Recipe:: default
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#

include_recipe '7-zip'

if node['sagecrm']['service']['account'] == ""
    raise "Please configure Sage CRM service_account attribute"
end

if node['sagecrm']['service']['password'] == ""
    raise "Please configure Sage CRM service_account_password attribute"
end

if node['sagecrm']['service']['password'] == ""
    raise "Please configure Sage CRM service_account_password attribute"
end

if node['sagecrm']['properties']['License']['Name']  == ""
    raise "Please configure Sage CRM license name attribute"
end

if node['sagecrm']['properties']['License']['Company'] == ""
    raise "Please configure Sage CRM license company attribute"
end

if node['sagecrm']['properties']['License']['Serial'] == ""
    raise "Please configure Sage CRM license serial attribute"
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

(node['sagecrm']['windows_features']).each do |feature|
	windows_feature feature do
	  action :install
	  all true
	end
end

::Chef::Recipe.send(:include, Windows::Helper)
filename = File.basename(node['sagecrm']['url']).downcase
fileextension = File.extname(filename)
download_path = "#{Chef::Config['file_cache_path']}/#{filename}"
extract_path = "#{Chef::Config['file_cache_path']}/#{node['sagecrm']['filename']}/#{node['sagecrm']['checksum']}"
winfriendly_extract_path = win_friendly_path(extract_path)
config_file_path = "#{extract_path}/setup.iss"

remote_file download_path do
  source node['sagecrm']['url']
  checksum node['sagecrm']['checksum']
end

execute 'Extract Sage CRM installation' do
  command "#{File.join(node['7-zip']['home'], '7z.exe')} x -y -o\"#{winfriendly_extract_path}\" #{download_path}"
  not_if { ::File.directory?(extract_path) }
end

template config_file_path do
  source 'setup.iss.erb'
end

windows_package node['sagecrm']['name'] do
  source "#{extract_path}/setup.exe"
  installer_type :custom
  options '/s /L0x0409 SageCRMstd'
end