# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet_x/minio/client'

# Implementation for the minio_policy_assignment type using the Resource API.
class Puppet::Provider::MinioPolicyAssignment::MinioPolicyAssignment < Puppet::ResourceApi::SimpleProvider
  def initialize
    @alias = PuppetX::Minio::Client.alias
  end

  def get(context)
    context.debug('Returning list of minio policy assignments')
    return [] unless PuppetX::Minio::Client.installed? || PuppetX::Minio::Client.alias_set?

    @instances = []

    PuppetX::Minio::Client.execute("admin user list #{@alias}").each do |json_user|
      # `mcli admin user info` returns an array
      json_user_info = PuppetX::Minio::Client.execute("admin user info #{@alias} #{json_user['accessKey']}").first
      @instances << to_puppet_policy_assignment(json_user_info, 'user')
    end

    # `mcli admin group list` returns an array
    json_groups = PuppetX::Minio::Client.execute("admin group list #{@alias}").first
    json_groups.fetch('groups', []).each do |group|
      # `mcli admin group info` returns an array
      json_group_info = PuppetX::Minio::Client.execute("admin group info #{@alias} #{group}").first
      @instances << to_puppet_policy_assignment(json_group_info, 'group')
    end

    @instances
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    PuppetX::Minio::Client.execute("admin policy set #{@alias} #{should[:policies].join(',')} #{should[:subject_type]}=#{should[:subject]}")
  end

  def create(context, name, should)
    context.warning('`create` method not implemented for `minio_policy_assignment` provider.')
  end

  def delete(context, name)
    context.warning('`delete` method not implemented for `minio_policy_assignment` provider.')
  end

  def to_puppet_policy_assignment(json, subject_type)
    case subject_type
    when 'user'
      subject = json.fetch('accessKey')
      policies = json.fetch('policyName', '').split(',')
    when 'group'
      subject = json.fetch('groupName')
      policies = json.fetch('groupPolicy', '').split(',')
    else
      raise Puppet::ExecutionFailure, "Unknown subject_type `#{subject_type}`. Supported values: user, group"
    end

    {
      ensure: 'present',
      title: "#{subject_type}_#{subject}",
      subject: subject,
      subject_type: subject_type,
      policies: policies,
    }
  end
end
