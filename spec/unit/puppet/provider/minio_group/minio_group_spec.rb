# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::MinioGroup')
require 'puppet/provider/minio_group/minio_group'

RSpec.describe Puppet::Provider::MinioGroup::MinioGroup do
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
          {"status": "success","groups": ["test-one","test-two"]}
          JSONSTRINGS
        when /test-one/
          out = <<-JSONSTRINGS
          {"status": "success","groupName": "test-one","members": ["user-one","user-two"],"groupStatus": "enabled","groupPolicy": "test-policy"}
          JSONSTRINGS
        else
          out = <<-JSONSTRINGS
          {"status": "success","groupName": "test-two","members": ["user-three","user-four"],"groupStatus": "enabled","groupPolicy": "consoleAdmin"}
          JSONSTRINGS
        end

        out
      end

      expect(context).to receive(:debug).with('Returning list of minio groups')
      expect(provider.get(context)).to eq [
        {
          name: 'test-one',
          ensure: 'present',
          members: ['user-one', 'user-two'],
          policies: ['test-policy'],
          enabled: true,
        },
        {
          name: 'test-two',
          ensure: 'present',
          members: ['user-three', 'user-four'],
          policies: ['consoleAdmin'],
          enabled: true,
        },
      ]
    end
  end

  describe 'create(context, name, should)' do
    it 'with defaults' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json admin group add puppet test-one user-one user-two'

        ''
      end
      expect(context).to receive(:notice).with(%r{\ACreating 'test-one'})

      provider.create(context, 'test-one',
                      name: 'test-one',
                      ensure: 'present',
                      members: ['user-one', 'user-two'],
                      enabled: true)
    end

    it 'with policies set' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        case command
        when /policy/
          expected_command = '/usr/local/sbin/minio-client --json admin policy set puppet custom-policy-one,custom-policy-two group=test-one'
        else
          expected_command = '/usr/local/sbin/minio-client --json admin group add puppet test-one user-one user-two'
        end
        expect(command).to eq(expected_command)

        ''
      end
      expect(context).to receive(:notice).with (%r{\ACreating 'test-one'})

      provider.create(context, 'test-one',
                      name: 'test-one',
                      ensure: 'present',
                      members: ['user-one', 'user-two'],
                      policies: ['custom-policy-one', 'custom-policy-two'],
                      enabled: true)
    end

    it 'with group disabled' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        case command
        when /disable/
          expected_command = '/usr/local/sbin/minio-client --json admin group disable puppet test-one'
        else
          expected_command = '/usr/local/sbin/minio-client --json admin group add puppet test-one user-one user-two'
        end
        expect(command).to eq(expected_command)

        ''
      end
      expect(context).to receive(:notice).with (%r{\ACreating 'test-one'})

      provider.create(context, 'test-one',
                      name: 'test-one',
                      ensure: 'present',
                      members: ['user-one', 'user-two'],
                      enabled: false)

    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'test-one'})

      expect(subject).to receive(:delete).with(context, 'test-one')
      expect(subject).to receive(:create).with(context, 'test-one',
                                               name: 'test-one',
                                               ensure: 'present',
                                               members: ['user-one'],
                                               enabled: false)

      provider.update(context, 'test-one',
                      name: 'test-one',
                      ensure: 'present',
                      members: ['user-one'],
                      enabled: false)
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        case command
        when /info/
          expected_command = '/usr/local/sbin/minio-client --json admin group info puppet test-one'
          out = <<-JSONSTRING
          {"status": "success","groupName": "test-one","members": ["user-one","user-two"],"groupStatus": "enabled","groupPolicy": "test-policy"}
          JSONSTRING
        when /user/
          expected_command = '/usr/local/sbin/minio-client --json admin group remove puppet test-one user-one user-two'
          out = ''
        else
          expected_command = '/usr/local/sbin/minio-client --json admin group remove puppet test-one'
          out = ''
        end

        expect(command).to eq(expected_command)
        out
      end
      expect(context).to receive(:notice).with(%r{\ADeleting 'test-one'})

      provider.delete(context, 'test-one')
    end
  end
end
