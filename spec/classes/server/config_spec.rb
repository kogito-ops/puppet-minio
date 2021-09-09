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

      let(:params) do
        {
          configuration: {},
          owner: 'minio',
          group: 'minio',
          configuration_directory: '/etc/minio',
          installation_directory: '/opt/minio',
          storage_root: '/var/minio',
          custom_configuration_file_path: '/etc/default/minio',
        }
      end

      context 'with all defaults' do
        it {
          is_expected.to compile
          is_expected.to contain_file('/etc/default/minio')
        }
      end

      context 'with multiple storage roots and no MINIO_DEPLOYMENT_DEFINITION' do
        let(:params) do
          super().merge(storage_root: ['/var/minio1', '/var/minio2'])
        end

        it {
          is_expected.to compile.and_raise_error(%r{Please provide a value for the MINIO_DEPLOYMENT_DEFINITION in configuration to run distributed or erasure-coded deployment.})
        }
      end

      context 'with multiple storage roots and MINIO_DEPLOYMENT_DEFINITION' do
        let(:params) do
          super().merge(
            storage_root: ['/var/minio1', '/var/minio2', '/var/minio3', '/var/minio4'],
            configuration: {
              MINIO_DEPLOYMENT_DEFINITION: '/var/minio{1...4}',
            },
          )
        end

        it {
          is_expected.to compile
          is_expected.to contain_file('/etc/default/minio')
        }
      end
    end
  end
end
