# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::MinioUser')
require 'puppet/provider/minio_user/minio_user'

RSpec.describe Puppet::Provider::MinioUser::MinioUser do
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
      Puppet::Util::ExecutionStub.set do |command, _options|
        case command
        when /list/
          out = <<-JSONSTRINGS
          {"status": "success","accessKey": "user-one","userStatus": "enabled"}
          {"status": "success","accessKey": "user-two","userStatus": "enabled"}
          JSONSTRINGS
        when /user-one/
          out = <<-JSONSTRINGS
          {"status": "success","accessKey": "user-one","userStatus": "enabled","memberOf": ["group-one"]}
          JSONSTRINGS
        else
          out = <<-JSONSTRINGS
          {"status": "success","accessKey": "user-two","policyName": "readonly,custom-policy","userStatus": "enabled"}
          JSONSTRINGS
        end

        out
      end

      expect(context).to receive(:debug).with('Returning list of minio users')
      expect(provider.get(context)).to eq [
        {
          access_key: 'user-one',
          ensure: 'present',
          policies: nil,
          member_of: ['group-one'],
        },
        {
          access_key: 'user-two',
          ensure: 'present',
          policies: ['readonly','custom-policy'],
          member_of: [],
        },
      ]
    end
  end

  describe 'create(context, name, should)' do
    it 'with defaults' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json admin user add puppet user-one MySecretPass'

        ''
      end
      expect(context).to receive(:notice).with(%r{\ACreating 'user-one'})

      provider.create(context, 'user-one',
                      ensure: 'present',
                      access_key: 'user-one',
                      secret_key: Puppet::Pops::Types::PSensitiveType::Sensitive.new('MySecretPass'))
    end

    it 'with policies' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        case command
        when /policy/
          expected_command = '/usr/local/sbin/minio-client --json admin policy set puppet readonly custom-policy user=user-one'
        else
          expected_command = '/usr/local/sbin/minio-client --json admin user add puppet user-one MySecretPass'
        end
        expect(command).to eq expected_command

        ''
      end
      expect(context).to receive(:notice).with(%r{\ACreating 'user-one'})

      provider.create(context, 'user-one',
                      ensure: 'present',
                      access_key: 'user-one',
                      secret_key: Puppet::Pops::Types::PSensitiveType::Sensitive.new('MySecretPass'),
                      policies: ['readonly', 'custom-policy'])
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json admin policy set puppet consoleAdmin user=user-one'

        ''
      end
      expect(context).to receive(:notice).with(%r{\AUpdating 'user-one'})

      provider.update(context, 'user-one',
                      ensure: 'present',
                      access_key: 'user-one',
                      policies: ['consoleAdmin'])
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json admin user remove puppet user-one'

        ''
      end
      expect(context).to receive(:notice).with(%r{\ADeleting 'user-one'})

      provider.delete(context, 'user-one')
    end
  end
end
