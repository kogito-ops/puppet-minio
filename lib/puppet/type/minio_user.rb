# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'minio_user',
  docs: <<-EOS,
@summary Manages local MinIO users
@example
  minio_user { 'userOne':
    ensure     => 'present',
    secret_key => Sensitive('password'),
    policies   => ['consoleAdmin', 'custom-policy'],
  }

**Autorequires**:
* `File[/root/.minioclient]`
* `Minio_client_alias[puppet]`
EOS
  features: ['custom_insync'],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    access_key: {
      type:      'String',
      desc:      'The API access key',
      behaviour: :namevar,
    },
    secret_key: {
      type: 'Variant[Sensitive[String], String]',
      desc: 'The API access secret',
    },
    policies: {
      type:    'Optional[Array[String]]',
      desc:    'List of MinIO PBAC policies to set for this user.',
    },
    member_of: {
      type:      'Optional[Array[String]]',
      desc:      'List of groups the user is a member of.',
      behaviour: :read_only,
    },
  },
)
