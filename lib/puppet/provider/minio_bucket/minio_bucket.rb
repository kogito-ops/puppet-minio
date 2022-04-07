# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet_x/minio/client'

# Implementation for the minio_bucket type using the Resource API.
class Puppet::Provider::MinioBucket::MinioBucket < Puppet::ResourceApi::SimpleProvider
  def initialize
    @alias = PuppetX::Minio::Client.alias
  end

  def get(context)
    context.debug('Returning list of minio buckets')
    return [] unless PuppetX::Minio::Client.installed? || PuppetX::Minio::Client.alias_set?

    @instances = []
    PuppetX::Minio::Client.execute("ls #{@alias}").each do |json_bucket|
      name = json_bucket['key'].chomp('/')
      # `mcli stat` returns an array
      data = PuppetX::Minio::Client.execute("stat #{@alias}/#{name}").first

      @instances << to_puppet_bucket(data)
    end
    @instances
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")

    flags = []
    flags << "--region=#{should[:region]}" if should[:region]
    flags << '--with-lock' if should[:enable_object_lock]

    PuppetX::Minio::Client.execute("mb #{flags.join(' ')} #{@alias}/#{name}")
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")

    operations = []
    operations << "retention clear #{@alias}/#{name}" unless should[:enable_object_lock]

    operations.each do |op|
      PuppetX::Minio::Client.execute(op)
    end
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    PuppetX::Minio::Client.execute("rb --force #{@alias}/#{name}")
  end

  def to_puppet_bucket(json)
    name = json['url'].delete_prefix("#{@alias}/")
    region = json['metadata']['location']
    enable_object_lock = ! json['metadata']['ObjectLock']['enabled'].empty?

    {
      ensure: 'present',
      name: name,
      region: region,
      enable_object_lock: enable_object_lock,
    }
  end

  def insync?(context, _name, property_name, is_hash, should_hash)
    context.debug("Checking whether #{property_name} is out of sync")
    case property_name
    when :region
      # It's not possible to move a bucket to a different region
      # after creation.
      true
    end
  end
end
