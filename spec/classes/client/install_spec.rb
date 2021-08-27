# frozen_string_literal: true

require 'spec_helper'

describe 'minio::client::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          package_ensure: 'present',
          base_url: 'https://dl.minio.io/client/mc/release',
          version: 'RELEASE.2021-07-27T06-46-19Z',
          checksum: '0df81285771e12e16a0c4c2f5e0ebc700e66abb8179013cc740d48b0abad49be',
          checksum_type: 'sha256',
          installation_directory: '/usr/local/bin',
          binary_name: 'minio-client',
        }
      end

      context 'with all defaults' do
        it {
          is_expected.to compile.with_all_deps
          is_expected.to contain_archive__download('/usr/local/bin/minio-client').with_ensure('present')
          is_expected.to contain_file('/usr/local/bin/minio-client').with_ensure('present').that_requires('Archive::Download[/usr/local/bin/minio-client]')
          is_expected.to contain_file('/root/.minioclient').with('ensure' => 'link').that_requires('File[/usr/local/bin/minio-client]')
        }
      end

      context 'with ensure => absent' do
        let(:params) do
          super().merge(package_ensure: 'absent')
        end

        it {
          is_expected.to compile.with_all_deps
          is_expected.to contain_archive__download('/usr/local/bin/minio-client').with_ensure('absent')
          is_expected.to contain_file('/usr/local/bin/minio-client').with_ensure('absent').that_requires('Archive::Download[/usr/local/bin/minio-client]')
          is_expected.to contain_file('/root/.minioclient').with('ensure' => 'absent').that_requires('File[/usr/local/bin/minio-client]')
        }
      end
    end
  end
end
