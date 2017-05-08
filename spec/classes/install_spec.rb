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
            checksum: '9e3b6b4fe6638f46ef1fd1b1b6e79552bc50f992bf56706f0500aa44b8906adf',
            checksum_type: 'sha256',
            owner: 'minio',
            group: 'minio',
            configuration_directory: '/etc/minio',
            installation_directory: '/opt/minio',
            storage_root: '/var/minio',
            log_directory: '/var/log/minio',
            manage_service: true,
            service_template: 'minio/systemd.erb',
            service_path: '/lib/systemd/system/minio.service',
            service_provider: 'systemd',
            service_mode: '0644'
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
    end
  end
end
