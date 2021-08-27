# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'minio_client_alias',
  docs: <<-EOS,
@summary Manages minio client aliases
@example
  minio_client_alias { 'localminio':
    ensure              => 'present',
    endpoint            => 'http://localhost:9000',
    access_key          => 'admin',
    secret_key          => 'password',
    api_signature       => 'S3v4',
    path_lookup_support =>'on',
  }

@example
  minio_client_alias { 'default':
    ensure     => 'present',
    endpoint   => 'http://localhost:9000',
    access_key => 'admin',
    secret_key => Sensitive('password'),
  }

**Autorequires**:
* `Class[minio::client]`
EOS
  features: ['custom_insync'],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    name: {
      type:      'String',
      desc:      'The name of the resource you want to manage.',
      behaviour: :namevar,
    },
    endpoint: {
      type:      'String[1]',
      desc:      'The API endpoint url',
    },
    access_key: {
      type:      'String[1]',
      desc:      'The API access key',
    },
    secret_key: {
      type:      'Variant[Sensitive[String[1]], String[1]]',
      desc:      'The API access secret',
    },
    api_signature: {
      type:      'Optional[String[1]]',
      desc:      'The API signature',
    },
    path_lookup_support: {
      type:      "Optional[Enum['on', 'off', 'auto']]",
      desc:      'Indicate whether dns or path style url requests are supported by the server.',
    },
  },
  autorequire: {
    class: 'minio::client::install',
  },
)
