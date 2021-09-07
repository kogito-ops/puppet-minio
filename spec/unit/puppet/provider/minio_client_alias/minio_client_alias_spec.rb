# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::MinioClientAlias')
require 'puppet/provider/minio_client_alias/minio_client_alias'

RSpec.describe Puppet::Provider::MinioClientAlias::MinioClientAlias do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  before :each do
    allow(context).to receive(:debug)
    allow(context).to receive(:notice)
    allow(File).to receive(:exist?).and_return(true)
    allow(File).to receive(:readlink).and_return('/usr/local/sbin/minio-client')
    Puppet::Util::ExecutionStub.set do |_command, _options|
      ''
    end
  end

  describe '#get' do
    it 'returns empty list when client is not installed' do
      allow(File).to receive(:exist?).and_return(false)
      expect(provider.get(context)).to eq []
    end

    it 'processes resources' do
      Puppet::Util::ExecutionStub.set do |_command, _options|
        <<-JSONSTRINGS
        {"status":"success","alias":"testing","URL":"http://localhost:9000","accessKey":"admin","secretKey":"password","api":"S3v4","path":"on"}
        {"status":"success","alias":"other","URL":"http://example.com","accessKey":"access","secretKey":"secret","api":"S3v2","path":"auto"}
        JSONSTRINGS
      end

      expect(context).to receive(:debug).with('Returning list of minio client aliases')
      expect(provider.get(context)).to eq [
        {
          name: 'testing',
          ensure: 'present',
          endpoint: 'http://localhost:9000',
          access_key: 'admin',
          secret_key: Puppet::Pops::Types::PSensitiveType::Sensitive.new('password'),
          api_signature: 'S3v4',
          path_lookup_support: 'on',
        },
        {
          name: 'other',
          ensure: 'present',
          endpoint: 'http://example.com',
          access_key: 'access',
          secret_key: Puppet::Pops::Types::PSensitiveType::Sensitive.new('secret'),
          api_signature: 'S3v2',
          path_lookup_support: 'auto',
        },
      ]
    end
  end

  it 'processes legacy paths' do
    Puppet::Util::ExecutionStub.set do |_command, _options|
      <<-JSONSTRINGS
      {"status":"success","alias":"test1","URL":"http://example.com","accessKey":"admin","secretKey":"password","api":"S3v4","path":""}
      {"status":"success","alias":"test2","URL":"http://example.com","accessKey":"access","secretKey":"secret","api":"S3v2","path":"dns"}
      {"status":"success","alias":"test3","URL":"http://example.com","accessKey":"access","secretKey":"secret","api":"S3v2","path":"path"}
      JSONSTRINGS
    end

    alisases = provider.get(context)
    expect(alisases).to include(a_hash_including(name: 'test1', path_lookup_support: 'auto'))
    expect(alisases).to include(a_hash_including(name: 'test2', path_lookup_support: 'off'))
    expect(alisases).to include(a_hash_including(name: 'test3', path_lookup_support: 'on'))
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json alias set test http://example.com access secret --api S3v4 --path on'

        ''
      end

      expect(context).to receive(:notice).with(%r{\ACreating 'test'})
      provider.create(context, 'test',
                      name: 'true',
                      ensure: 'present',
                      endpoint: 'http://example.com',
                      access_key: 'access',
                      secret_key: 'secret',
                      api_signature: 'S3v4',
                      path_lookup_support: 'on')
    end

    it 'does not add api signature when not provided in puppet resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json alias set test http://example.com access secret --path on'

        ''
      end

      provider.create(context, 'test',
                      name: 'true',
                      ensure: 'present',
                      endpoint: 'http://example.com',
                      access_key: 'access',
                      secret_key: 'secret',
                      path_lookup_support: 'on')
    end

    it 'does not add path when not provided in puppet resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json alias set test http://example.com access secret --api S3v4'

        ''
      end

      provider.create(context, 'test',
                      name: 'true',
                      ensure: 'present',
                      endpoint: 'http://example.com',
                      access_key: 'access',
                      secret_key: 'secret',
                      api_signature: 'S3v4')
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})

      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json alias set foo http://example.com access secret'

        ''
      end

      provider.update(context, 'foo',
                      name: 'foo',
                      ensure: 'present',
                      endpoint: 'http://example.com',
                      access_key: 'access',
                      secret_key: 'secret')
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})

      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json alias remove foo'

        ''
      end

      provider.delete(context, 'foo')
    end
  end

  describe 'insync?(context, name, property_name, is_hash, should_hash)' do # rubocop:disable RSpec/EmptyExampleGroup
    def self.test_insync_of_secret_key(desc, is, should, expected)
      it desc do
        is_hash = { secret_key: is }
        should_hash = { secret_key: should }
        expect(context).to receive(:debug).with(%r{\AChecking whether secret_key is out of sync})
        expect(provider.insync?(context, 'test', :secret_key, is_hash, should_hash)).to eq(expected)
      end
    end

    test_insync_of_secret_key 'in sync with two equal strings', 'password', 'password', true
    test_insync_of_secret_key 'in sync with two equal sensitives', Puppet::Pops::Types::PSensitiveType::Sensitive.new('password'), Puppet::Pops::Types::PSensitiveType::Sensitive.new('password'), true
    test_insync_of_secret_key 'in sync with existing existing string and expected sensitive', 'password', Puppet::Pops::Types::PSensitiveType::Sensitive.new('password'), true
    test_insync_of_secret_key 'in sync with existing sensitive and expected string', Puppet::Pops::Types::PSensitiveType::Sensitive.new('password'), 'password', true
    test_insync_of_secret_key 'not in sync with mismatching strings', 'something', 'other', false
  end
end
