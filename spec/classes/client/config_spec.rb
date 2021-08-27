# frozen_string_literal: true

require 'spec_helper'

describe 'minio::client::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'purge_unmanaged_aliases => true' do
        let(:params) do
          {
            aliases: {},
            purge_unmanaged_aliases: true,
          }
        end

        it {
          is_expected.to compile
          is_expected.to contain_resources('minio_client_alias').with('purge' => true)
        }
      end

      context 'purge_unmanaged_aliases => false' do
        let(:params) do
          {
            aliases: {},
            purge_unmanaged_aliases: false,
          }
        end

        it {
          is_expected.to compile
          is_expected.not_to contain_resources('minio_client_alias')
        }
      end

      context 'creates aliases' do
        let(:params) do
          {
            aliases: {
              'default' => {
                'ensure'              => 'present',
                'endpoint'            => 'http://localhost:9000',
                'access_key'          => 'admin',
                'secret_key'          => 'password',
                'api_signature'       => 'S3v4',
                'path_lookup_support' => 'on',
              },
            },
            purge_unmanaged_aliases: false,
          }
        end

        it {
          is_expected.to compile
          is_expected.to contain_minio_client_alias('default').with(
            'ensure' => 'present',
            'endpoint'            => 'http://localhost:9000',
            'access_key'          => 'admin',
            'secret_key'          => 'password',
            'api_signature'       => 'S3v4',
            'path_lookup_support' => 'on',
          )
        }
      end
    end
  end
end
