# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::MinioBucket')
require 'puppet/provider/minio_bucket/minio_bucket'

RSpec.describe Puppet::Provider::MinioBucket::MinioBucket do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  before :each do
    allow(context).to receive(:debug)
    allow(context).to receive(:notice)
    allow(context).to receive(:warning)
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
        {"status": "success","type": "folder","lastModified": "1970-01-01T00:00:00.000+01:00","size": 0,"key": "bucket-one/","etag": "","url": "http://localhost:9200","versionOrdinal": 1}
        {"status": "success","type": "folder","lastModified": "1970-01-01T00:00:00.000+01:00","size": 0,"key": "bucket-two/","etag": "","url": "http://localhost:9200","versionOrdinal": 1}
        JSONSTRINGS
      end

      expect(context).to receive(:debug).with('Returning list of minio buckets')
      expect(provider.get(context)).to eq [
        {
          name: 'bucket-one',
          ensure: 'present',
        },
        {
          name: 'bucket-two',
          ensure: 'present',
        },
      ]
    end
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json mb puppet/bucket-one'

        ''
      end

      expect(context).to receive(:notice).with(%r{\ACreating 'bucket-one'})
      provider.create(context, 'bucket-one', name: 'bucket-one', ensure: 'present')
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      expect(context).to receive(:warning).with('`update` method not implemented for `minio_bucket` provider')
      provider.update(context, 'bucket-one', name: 'bucket-one-test', ensure: 'present')
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      Puppet::Util::ExecutionStub.set do |command, _options|
        expect(command).to eq '/usr/local/sbin/minio-client --json rb --force puppet/bucket-one'

        ''
      end

      expect(context).to receive(:notice).with(%r{\ADeleting 'bucket-one'})
      provider.delete(context, 'bucket-one')
    end
  end
end
