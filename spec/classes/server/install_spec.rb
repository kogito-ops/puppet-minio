# frozen_string_literal: true

require 'spec_helper'

describe 'minio::server::install', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      let(:pre_condition) do
        "class { 'minio::server::config':
          configuration => {},
          owner => 'minio',
          group => 'minio',
          configuration_directory => '/etc/minio',
          installation_directory => '/opt/minio',
          storage_root => '/var/minio',
        }
        class { 'minio::server::service':
          manage_service => true,
          service_provider => 'systemd',
          service_ensure => 'running',
        }"
      end

      context 'with all defaults' do
        let :params do
          {
            package_ensure: 'present',
            base_url: 'https://dl.minio.io/server/minio/release',
            version: 'RELEASE.2017-09-29T19-16-56Z',
            checksum: 'b7707b11c64e04be87b4cf723cca5e776b7ed3737c0d6b16b8a3d72c8b183135',
            checksum_type: 'sha256',
            owner: 'minio',
            group: 'minio',
            configuration_directory: '/etc/minio',
            installation_directory: '/opt/minio',
            storage_root: '/var/minio',
            listen_ip: '127.0.0.1',
            listen_port: 9000,
            manage_service: true,
            service_template: 'minio/systemd.erb',
            service_provider: 'systemd',
          }
        end

        it { is_expected.to contain_archive__download('/opt/minio/minio') }
        it { is_expected.to contain_file('/etc/minio') }
        it { is_expected.to contain_file('/opt/minio') }
        it { is_expected.to contain_file('/opt/minio/minio') }
        it { is_expected.to contain_file('/var/minio') }
        it { is_expected.to contain_systemd__unit_file('minio.service') }
        it { is_expected.to contain_exec('permissions:/etc/minio') }
        it { is_expected.to contain_exec('permissions:/opt/minio') }
        it { is_expected.to contain_exec('permissions:/var/minio') }
      end
    end
  end
end
