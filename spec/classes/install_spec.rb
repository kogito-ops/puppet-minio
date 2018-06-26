require 'spec_helper'

describe 'minio::install', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
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
            log_directory: '/var/log/minio',
            listen_ip: '127.0.0.1',
            listen_port: 9000,
            manage_service: true,
            service_template: 'minio/systemd.erb',
            service_path: '/lib/systemd/system/minio.service',
            service_provider: 'systemd',
            service_mode: '0644',
            provider: 'remote_file',
          }
        end

        it { is_expected.to contain_remote_file('minio') }
        it { is_expected.to contain_file('/etc/minio') }
        it { is_expected.to contain_file('/opt/minio') }
        it { is_expected.to contain_file('/var/log/minio') }
        it { is_expected.to contain_file('/var/minio') }
        it { is_expected.to contain_file('service:/lib/systemd/system/minio.service') }
        it { is_expected.to contain_exec('permissions:/etc/minio') }
        it { is_expected.to contain_exec('permissions:/opt/minio') }
        it { is_expected.to contain_exec('permissions:/opt/minio/minio') }
        it { is_expected.to contain_exec('permissions:/var/log/minio') }
        it { is_expected.to contain_exec('permissions:/var/minio') }
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
            log_directory: '/var/log/minio',
            listen_ip: '127.0.0.1',
            listen_port: 9000,
            manage_service: true,
            service_template: 'minio/systemd.erb',
            service_path: '/lib/systemd/system/minio.service',
            service_provider: 'systemd',
            service_mode: '0644',
            provider: 'archive',
          }
        end
        it { is_expected.to_not contain_remote_file('minio') }
        it {
          is_expected.to contain_file('minio')
        }
        it {
          case facts[:architecture]
          when 'x86_64'
            arch = 'amd64'
          when 'x86'
            arch = '386'
          else
            arch = facts[:architecture]
          end
          is_expected.to contain_archive("https://dl.minio.io/server/minio/release/linux-#{arch}/archive/minio.RELEASE.2017-09-29T19-16-56Z")
            .that_subscribes_to('File[minio]')
        }
      end
    end
  end
end
