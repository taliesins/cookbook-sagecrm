#
# Cookbook Name:: sagecrm
# Recipe:: default
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'autoit'
include_recipe 'seven_zip'

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

working_directory = File.join(Chef::Config['file_cache_path'], '/sagecrm')

directory working_directory do
  recursive true
end

sagecrm_install_script_path = File.join(working_directory, 'SageCrmInstall.au3')
sagecrm_install_exe_path = File.join(working_directory, 'SageCrmInstall.exe')

win_friendly_sagecrm_install_script_path = win_friendly_path(sagecrm_install_script_path)
win_friendly_sagecrm_install_exe_path = win_friendly_path(sagecrm_install_exe_path)

sagecrm_installed = is_package_installed?("#{node['sagecrm']['name']}")
filename = File.basename(node['sagecrm']['url']).downcase
download_path = File.join(working_directory, filename)

installation_directory = File.join(working_directory, node['sagecrm']['checksum'])
win_friendly_installation_directory = win_friendly_path(installation_directory)

template sagecrm_install_script_path do
  source 'SageCrmInstall.au3.erb'
  variables(
    WorkingDirectory: win_friendly_installation_directory
  )
  not_if {sagecrm_installed}
end

execute "Check syntax #{win_friendly_sagecrm_install_script_path} with AutoIt" do
  command "\"#{File.join(node['autoit']['home'], '/Au3Check.exe')}\" \"#{win_friendly_sagecrm_install_script_path}\""
  not_if {sagecrm_installed}
end

execute "Compile #{win_friendly_sagecrm_install_script_path} with AutoIt" do
  command "\"#{File.join(node['autoit']['home'], '/Aut2Exe/Aut2exe.exe')}\" /in \"#{win_friendly_sagecrm_install_script_path}\" /out \"#{win_friendly_sagecrm_install_exe_path}\" "
  not_if {sagecrm_installed}
end

remote_file download_path do
  source node['sagecrm']['url']
  checksum node['sagecrm']['checksum']
  not_if {sagecrm_installed}
end

execute "Exract #{download_path} To #{win_friendly_installation_directory}" do
  command "\"#{File.join(node['seven_zip']['home'], '7z.exe')}\" x -y -o\"#{win_friendly_installation_directory}\" #{download_path}"
  not_if {sagecrm_installed  || ::File.directory?(installation_directory)}
end

win_friendly_psexec_path = win_friendly_path(File.join(node['pstools']['home'], 'psexec.exe'))
win_friendly_rdpplus_path = win_friendly_path(File.join(node['rdpplus']['home'], 'rdp.exe'))
win_friendly_powershell_helper_path = win_friendly_path(File.join(node['autoit']['home'], 'Invoke-InDesktopSession.ps1'))

powershell_script 'Install-SageCrm' do
    code <<-EOH1
$VerbosePreference = 'Continue'
. "#{win_friendly_powershell_helper_path}"

$username = '#{node['sagecrm']['installaccount']['account']}'
$password = '#{node['sagecrm']['installaccount']['password']}'
$command = '#{win_friendly_sagecrm_install_exe_path}'
$psexecPath = '#{win_friendly_psexec_path}'
$rdpplusPath = '#{win_friendly_rdpplus_path}'

$ErrorActionPreference = "Stop"  

#We are unable to run the installer in a way that will allow it to start sage crm services in interactive mode. If the services exist that means the install is complete.
$ScreenshotsDirectory='#{win_friendly_installation_directory}'
Write-Verbose "Screenshots from installer steps should be available in $ScreenshotsDirectory"
Write-Verbose "Running: Invoke-InDesktopSession -username $username -password $password -command $command -psexecPath $psexecPath -rdpplusPath $rdpplusPath -timeOutMinutes 20"
$result = Invoke-InDesktopSession -username $username -password $password -command $command -psexecPath $psexecPath -rdpplusPath $rdpplusPath -timeOutMinutes 20

if ($result.StandardOutput){
	Write-Verbose "StandardOutput: $($result.StandardOutput)"
}

$sageCrmServices = get-service | ?{$_.Name -eq 'SageCRMQuickFindService' -or $_.Name -eq 'CRMIntegrationService' -or $_.Name -eq 'CRMIndexerService' -or $_.Name -eq 'CRMEscalationService'}

if ($sageCrmServices) {
	$sageCrmServices | stop-service
	if ($result.ErrorOutput){
		Write-Verbose "ErrorOutput: $($result.ErrorOutput)"
	}
	exit 0
} else {
	throw [PsCustomObject]@{
			Message = "Sage services not found, so concluding that running of the installer didn't install Sage correctly. Screenshots from installer steps should be available in $ScreenshotsDirectory."
			CommandInvokeResult = $result | ConvertTo-Json <# Need to serialize here because only 1st level of object gets serialized to output #>
		}
}

EOH1
    action :run
    not_if {sagecrm_installed}
end
