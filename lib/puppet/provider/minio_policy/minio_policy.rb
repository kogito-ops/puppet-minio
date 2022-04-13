# frozen_string_literal: true

require 'json'
require 'tempfile'

require 'puppet/resource_api/simple_provider'
require 'puppet_x/minio/client'

# Implementation for the minio_policy type using the Resource API.
class Puppet::Provider::MinioPolicy::MinioPolicy < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('Returning list of minio policies')
    return [] unless PuppetX::Minio::Client.installed? || PuppetX::Minio::Client.alias_set?

    json_policies = PuppetX::Minio::Client.execute("admin policy list #{PuppetX::Minio::Client.alias}")
    return [] if json_policies.empty?

    @instances = []
    json_policies.each do |policy|
      # `mcli admin policy info` returns an array
      json_policy_info = PuppetX::Minio::Client.execute("admin policy info #{PuppetX::Minio::Client.alias} #{policy['policy']}").first
      @instances << to_puppet_policy(json_policy_info)
    end
    @instances
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")

    f = Tempfile.new(["#{name}-policy", '.json'])
    begin
      json_policy = {:Version => should[:version], :Statement => should[:statement]}.to_json

      f.write(json_policy)
      f.rewind

      PuppetX::Minio::Client.execute("admin policy add #{PuppetX::Minio::Client.alias} #{name} #{f.path}")
    ensure
      f.close
      f.unlink
    end
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")

    # There's currently no way to update an existing policy via the client,
    # so delete and recreate the policy
    delete(context, name)
    create(context, name, should)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")
    PuppetX::Minio::Client.execute("admin policy remove #{PuppetX::Minio::Client.alias} #{name}")
  end

  def to_puppet_policy(json)
    statements = []
    json['policyJSON']['Statement'].each do |s|
      statements << sanitize_statement(s)
    end

    {
      ensure: 'present',
      name: json['policy'],
      version: json['policyJSON']['Version'],
      statement: statements,
    }
  end

  def sanitize_statement(statement)
    statement.transform_keys!(&:capitalize)

    ['Action', 'Resource', :Action, :Resource].each do |k|
      statement[k].sort! unless statement[k].nil?
    end

    statement
  end

  def canonicalize(_context, resources)
    resources.each do |r|
      unless r[:statement].nil?
        r[:statement].each do |s|
          s = sanitize_statement(s)
        end
      end
    end
  end
end
