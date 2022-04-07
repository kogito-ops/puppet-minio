# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet_x/minio/client'
require 'puppet_x/minio/util'

STATUS_MAP ||= {
  'enabled': true,
  'disabled': false
}.freeze

# Implementation for the minio_user type using the Resource API.
class Puppet::Provider::MinioUser::MinioUser < Puppet::ResourceApi::SimpleProvider
  include PuppetX::Minio::Util

  def initialize
    @alias = PuppetX::Minio::Client.alias
  end

  def get(context)
    context.debug('Returning list of minio users')
    return [] unless PuppetX::Minio::Client.installed? || PuppetX::Minio::Client.alias_set?

    @instances = []
    PuppetX::Minio::Client.execute("admin user list #{@alias}").each do |json_user|
      # `mcli admin user info` returns an array
      json_user_info = PuppetX::Minio::Client.execute("admin user info #{@alias} #{json_user['accessKey']}").first
      @instances << to_puppet_user(json_user_info)
    end
    @instances
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")

    operations = []
    operations << ["admin user add #{@alias} #{should[:access_key]} #{unwrap_maybe_sensitive(should[:secret_key])}", sensitive: true]
    operations << ["admin user disable #{@alias} #{should[:access_key]}"] unless should[:enabled]

    operations.each do |op|
      PuppetX::Minio::Client.execute(*op)
    end
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")

    operations = []
    operations << "admin user disable #{@alias} #{name}" unless should[:enabled]

    operations.each do |op|
      PuppetX::Minio::Client.execute(op)
    end
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    PuppetX::Minio::Client.execute("admin user remove #{@alias} #{name}")
  end

  def insync?(context, _name, property_name, is_hash, should_hash)
    context.debug("Checking whether #{property_name} is out of sync")
    case property_name
    when :secret_key
      # Let Puppet believe that the resource doesn't need updating,
      # since we can't check a user's secret key
      true
    end
  end

  def to_puppet_user(json)
    {
      ensure: 'present',
      access_key: json['accessKey'],
      enabled: STATUS_MAP[json['userStatus'].to_sym],
    }
  end
end
