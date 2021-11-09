# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet_x/minio/client'

DEFAUlT_TARGET_ALIAS ||= 'puppet'.freeze

# Implementation for the minio_bucket type using the Resource API.
class Puppet::Provider::MinioBucket::MinioBucket < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('Returning list of minio buckets')
    return [] unless PuppetX::Minio::Client.installed?

    @instances = []
    PuppetX::Minio::Client.execute("ls #{DEFAUlT_TARGET_ALIAS}").each do |json_bucket|
      @instances << to_puppet_bucket(json_bucket)
    end
    @instances
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    PuppetX::Minio::Client.execute("mb #{DEFAUlT_TARGET_ALIAS}/#{name}")
  end

  def update(context, name, should)
    context.warning('`update` method not implemented for `minio_bucket` provider')
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    PuppetX::Minio::Client.execute("rb --force #{DEFAUlT_TARGET_ALIAS}/#{name}")
  end

  def to_puppet_bucket(json)
    # Delete trailing slashes from bucket name
    name = json['key'].chomp('/')

    {
      ensure: 'present',
      name: name,
    }
  end
end
