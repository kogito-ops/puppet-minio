# frozen_string_literal: true

require 'json'
require 'puppet/resource_api/simple_provider'
require 'puppet_x/minio/client'

LEGACY_PATH_SUPPORT_MAP ||= {
  '': 'auto',
  dns: 'off',
  path: 'on',
}.freeze

# Implementation for the minio_client_alias type using the Resource API.
class Puppet::Provider::MinioClientAlias::MinioClientAlias < Puppet::ResourceApi::SimpleProvider
  def get(context)
    context.debug('Returning list of minio client aliases')
    return [] unless PuppetX::Minio::Client.installed?

    @instances = []
    PuppetX::Minio::Client.execute('alias list', sensitive: true).each do |json_alias|
      @instances << to_puppet_alias(json_alias)
    end
    @instances
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")

    PuppetX::Minio::Client.execute("alias set #{to_client_params(name, should)}", sensitive: true)
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    PuppetX::Minio::Client.execute("alias set #{to_client_params(name, should)}", sensitive: true)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")

    PuppetX::Minio::Client.execute("alias remove #{name}")
  end

  def insync?(context, _name, property_name, is_hash, should_hash)
    context.debug("Checking whether #{property_name} is out of sync")
    case property_name
    when :secret_key
      is = unwrap_maybe_sensitive(is_hash[property_name])
      should = unwrap_maybe_sensitive(should_hash[property_name])
      is == should
    end
  end

  def to_client_params(name, should)
    params = [
      name,
      should[:endpoint],
      should[:access_key],
      unwrap_maybe_sensitive(should[:secret_key]),
    ]
    params << "--api #{should[:api_signature]}" unless should[:api_signature].nil?
    params << "--path #{should[:path_lookup_support]}" unless should[:path_lookup_support].nil?

    params.join(' ')
  end

  def to_puppet_alias(json)
    path_lookup_support = json['path']

    if LEGACY_PATH_SUPPORT_MAP.key?(json['path'].to_sym)
      path_lookup_support = LEGACY_PATH_SUPPORT_MAP[json['path'].to_sym]
    end

    {
      name: json['alias'],
      ensure: 'present',
      endpoint: json['URL'],
      access_key: json['accessKey'],
      secret_key: Puppet::Pops::Types::PSensitiveType::Sensitive.new(json['secretKey'] || ''),
      api_signature: json['api'],
      path_lookup_support: path_lookup_support,
    }
  end

  def unwrap_maybe_sensitive(param)
    if param.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)
      return param.unwrap
    end

    param
  end
end
