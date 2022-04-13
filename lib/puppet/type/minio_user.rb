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
* `File[/root/.minio_default_alias]`
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
      desc:      'API access key. This can also be used as a username.',
      behaviour: :namevar,
    },
    secret_key: {
      type: 'Variant[Sensitive[String[8, 40]], String[8, 40]]',
      desc: 'API access secret or password.',
    },
    enabled: {
      type: 'Optional[Boolean]',
      desc: 'Enables/Disables this user account',
      default: true,
    },
  },
)
