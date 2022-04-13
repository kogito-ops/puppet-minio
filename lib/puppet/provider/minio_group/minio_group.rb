# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet_x/minio/client'

GROUP_STATUS_MAP ||= {
  'enabled': true,
  'disabled': false,
}.freeze

# Implementation for the minio_group type using the Resource API.
class Puppet::Provider::MinioGroup::MinioGroup < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('Returning list of minio groups')
    return [] unless PuppetX::Minio::Client.installed? || PuppetX::Minio::Client.alias_set?

    # `mcli admin group list` returns an array
    json_groups = PuppetX::Minio::Client.execute("admin group list #{PuppetX::Minio::Client.alias}").first
    return [] unless json_groups.key?('groups')

    @instances = []
    json_groups['groups'].each do |group|
      # `mcli admin group info` returns an array
      json_group_info = PuppetX::Minio::Client.execute("admin group info #{PuppetX::Minio::Client.alias} #{group}").first
      @instances << to_puppet_group(json_group_info)
    end
    @instances
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")

    operations = []
    operations << "admin group add #{PuppetX::Minio::Client.alias} #{name} #{should[:members].join(' ')}"
    operations << "admin group disable #{PuppetX::Minio::Client.alias} #{name}" unless should[:enabled]

    operations.each do |op|
      PuppetX::Minio::Client.execute(op)
    end
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")

    # TODO: Do a proper update instead of recreating the group
    delete(context, name)
    create(context, name, should)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")

    members = PuppetX::Minio::Client.execute("admin group info #{PuppetX::Minio::Client.alias} #{name}").first['members']
    operations = []

    operations << "admin group remove #{PuppetX::Minio::Client.alias} #{name} #{members.join(' ')}"
    operations << "admin group remove #{PuppetX::Minio::Client.alias} #{name}"

    operations.each do |op|
      PuppetX::Minio::Client.execute(op)
    end
  end

  def to_puppet_group(json)
    policies = if json['groupPolicy'].nil? then nil else json['groupPolicy'].split(',') end

    {
      ensure: 'present',
      name: json['groupName'],
      members: json['members'] || [],
      enabled:  GROUP_STATUS_MAP[json['groupStatus'].to_sym],
    }
  end
end
