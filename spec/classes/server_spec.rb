# frozen_string_literal: true

require 'spec_helper'

describe 'minio::server', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        let :params do
          {
            package_ensure: 'present',
            owner: 'minio',
            group: 'minio',
            base_url: 'https://dl.minio.io/server/minio/release',
            version: 'RELEASE.2021-08-20T18-32-01Z',
            checksum: '0bf72d6fd0a88fee35ac598a1e7a5c90c78b53b6db3988414e34535fb6cf420c',
            checksum_type: 'sha256',
            configuration_directory: '/etc/minio',
            installation_directory: '/opt/minio',
            storage_root: '/var/minio',
            listen_ip: '127.0.0.1',
            listen_port: 9000,
            configuration: {},
            manage_service: true,
            service_template: 'minio/systemd.erb',
            service_provider: 'systemd',
            service_ensure: 'running',
          }
        end

        it {
          is_expected.to compile.with_all_deps
          is_expected.to contain_class('minio::server::install')
          is_expected.to contain_class('minio::server::config').that_requires('Class[minio::server::install]')
          is_expected.to contain_class('minio::server::service').that_requires('Class[minio::server::config]')
          is_expected.to contain_class('minio::server::service').that_subscribes_to(['Class[minio::server::install]', 'Class[minio::server::config]'])
        }
      end
    end
  end
end
