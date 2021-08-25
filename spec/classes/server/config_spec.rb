# frozen_string_literal: true

require 'spec_helper'

describe 'minio::server::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:pre_condition) do
        "class { 'minio::server::service':
            manage_service => true,
            service_provider => 'systemd',
            service_ensure => 'running',
        }"
      end

      context 'with all defaults' do
        let :params do
          {
            configuration: {},
            owner: 'minio',
            group: 'minio',
            configuration_directory: '/etc/minio',
            installation_directory: '/opt/minio',
            storage_root: '/var/minio',
          }
        end

        it { is_expected.to contain_file('/etc/minio/config') }
      end
    end
  end
end
