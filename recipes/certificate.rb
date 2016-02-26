#
# Cookbook Name:: sagecrm
# Recipe:: certificate
#
# Copyright (C) 2015 Taliesin Sisson
#
# All rights reserved - Do Not Redistribute
#

if node['sagecrm']['instance']['FarmCertificateThumbprint'] == ''
	ssl_certificate node['sagecrm']['certificate']['CaCertificate']['common_name'] do
		common_name node['sagecrm']['certificate']['CaCertificate']['common_name']
		cert_source node['sagecrm']['certificate']['CaCertificate']['cert_source']
		key_source node['sagecrm']['certificate']['CaCertificate']['key_source']
		cert_path node['sagecrm']['certificate']['CaCertificate']['cert_path']
		key_path node['sagecrm']['certificate']['CaCertificate']['key_path']
		pkcs12_path node['sagecrm']['certificate']['CaCertificate']['pkcs12_path']
		pkcs12_passphrase node['sagecrm']['certificate']['CaCertificate']['pkcs12_passphrase']
		namespace node['sagecrm']['certificate']['CaCertificate']
		only_if { node['sagecrm']['instance']['FarmCertificateThumbprint'] == ''}
	end

	windows_certificate node['sagecrm']['certificate']['CaCertificate']['common_name'] do
		source node['sagecrm']['certificate']['CaCertificate']['pkcs12_path']
		pfx_password node['sagecrm']['certificate']['CaCertificate']['pkcs12_passphrase']
		private_key_acl node['sagecrm']['certificate']['CaCertificate']['private_key_acl']
		store_name node['sagecrm']['certificate']['CaCertificate']['store_name']
		user_store node['sagecrm']['certificate']['CaCertificate']['user_store']
		only_if { node['sagecrm']['instance']['FarmCertificateThumbprint'] == ''}
	end	

	ssl_certificate node['sagecrm']['certificate']['FarmCertificate']['common_name'] do
		common_name node['sagecrm']['certificate']['FarmCertificate']['common_name']
		cert_source node['sagecrm']['certificate']['FarmCertificate']['cert_source']
		ca_cert_path node['sagecrm']['certificate']['FarmCertificate']['ca_cert_path']
		ca_key_path node['sagecrm']['certificate']['FarmCertificate']['ca_key_path']	
		pkcs12_path node['sagecrm']['certificate']['FarmCertificate']['pkcs12_path']
		pkcs12_passphrase node['sagecrm']['certificate']['FarmCertificate']['pkcs12_passphrase']
		namespace node['sagecrm']['certificate']['FarmCertificate']
		only_if { node['sagecrm']['instance']['FarmCertificateThumbprint'] == '' }
	end

	windows_certificate node['sagecrm']['certificate']['FarmCertificate']['common_name'] do
		source node['sagecrm']['certificate']['FarmCertificate']['pkcs12_path']
		pfx_password node['sagecrm']['certificate']['FarmCertificate']['pkcs12_passphrase']
		private_key_acl node['sagecrm']['certificate']['FarmCertificate']['private_key_acl']
		store_name node['sagecrm']['certificate']['FarmCertificate']['store_name']
		user_store node['sagecrm']['certificate']['FarmCertificate']['user_store']
		only_if { node['sagecrm']['instance']['FarmCertificateThumbprint'] == '' }
	end	
end