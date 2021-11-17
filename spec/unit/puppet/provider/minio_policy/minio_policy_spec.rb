# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::MinioPolicy')
require 'puppet/provider/minio_policy/minio_policy'

RSpec.describe Puppet::Provider::MinioPolicy::MinioPolicy do
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
          {"status": "success","policy": "test-one","isGroup": false}
          JSONSTRINGS
        else
          out = <<-JSONSTRINGS
          {"status": "success","policy": "test-one","isGroup": false,"policyJSON": {"Version": "2012-10-17","Statement": [{"Effect": "Allow","Action": ["s3:ListBucket"],"Resource": ["arn:aws:s3:::test-one-bucket-*"]},{"Effect": "Allow","Action": ["s3:GetObject","s3:PutObject"],"Resource": ["arn:aws:s3:::test-one-*"]}]}}
          JSONSTRINGS
        end

        out
      end

      expect(context).to receive(:debug).with('Returning list of minio policies')
      expect(provider.get(context)).to eq [
        {
          name: 'test-one',
          ensure: 'present',
          version: '2012-10-17',
          statement: [  # Using hash rockets, since Puppet returns strings as hash keys
            {
              'Effect'   => 'Allow',
              'Action'   => ['s3:ListBucket'],
              'Resource' => ['arn:aws:s3:::test-one-bucket-*'],
            },
            {
              'Effect'   => 'Allow',
              'Action'   => ['s3:GetObject','s3:PutObject'],
              'Resource' => ['arn:aws:s3:::test-one-*'],
            },
          ],
        },
      ]
    end
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to include '/usr/local/sbin/minio-client --json admin policy add puppet test-one'

        ''
      end
      expect(context).to receive(:notice).with(%r{\ACreating 'test-one'})

      provider.create(context, 'test-one',
                      name: 'test-one',
                      ensure: 'present',
                      statement: [
                        {
                          Effect: 'Allow',
                          Action:['s3:ListBucket'],
                          Resource: ['arn:aws:s3:::test-one-bucket-*'],
                        }
                      ])
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:notice).with(%r{\AUpdating 'test-one'})

      expect(subject).to receive(:delete).with(context, 'test-one')
      expect(subject).to receive(:create).with(context, 'test-one',
                                               name: 'test-one',
                                               ensure: 'present',
                                               statement: [
                                                 {
                                                   Effect: 'Allow',
                                                   Action:['s3:ListBucket'],
                                                   Resource: ['arn:aws:s3:::test-one-bucket-*'],
                                                 }
                                               ])

    provider.update(context, 'test-one',
                    name: 'test-one',
                    ensure: 'present',
                    statement: [
                      {
                        Effect: 'Allow',
                        Action:['s3:ListBucket'],
                        Resource: ['arn:aws:s3:::test-one-bucket-*'],
                      }
                    ])
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json admin policy remove puppet test-one'

        ''
      end
      expect(context).to receive(:notice).with(%r{\ADeleting 'test-one'})

      provider.delete(context, 'test-one')
    end
  end

  describe 'sanitize_statement(statement)' do
    def self.test_sanitize_statement(desc, input)
      expected = {:Effect => 'Allow', :Action => ['s3:GetObject', 's3:PutObject'], :Resource => ['arn:aws:s3:::test-one-bucket-*']}

      it desc do
        expect(provider.sanitize_statement(input)).to eq expected
      end
    end

    test_sanitize_statement 'capitalizes keys', {'effect': 'Allow', 'action': ['s3:GetObject', 's3:PutObject'], 'resource': ['arn:aws:s3:::test-one-bucket-*']}
    test_sanitize_statement 'sorts Action and Resource arrays', {'Effect': 'Allow', 'Action': ['s3:PutObject', 's3:GetObject'], 'Resource': ['arn:aws:s3:::test-one-bucket-*']}
  end
end
