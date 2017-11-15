require 'spec_helper'

describe 'minio::config', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os} " do
      let :facts do
        facts
      end

      context 'with all defaults' do
        let :params do
          {
            configuration: {
              'version' => '19',
              'credential' => {
                'accessKey' => 'ADMIN',
                'secretKey' => 'PASSWORD',
              },
              'region' => 'us-east-1',
              'browser' => 'on',
            },
            owner: 'minio',
            group: 'minio',
            configuration_directory: '/etc/minio',
            installation_directory: '/opt/minio',
            storage_root: '/var/minio',
            log_directory: '/var/log/minio',
          }
        end

        it { is_expected.to contain_file('/etc/minio/config.json') }
      end
    end
  end
end
