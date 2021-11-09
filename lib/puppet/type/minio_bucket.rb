# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'minio_bucket',
  docs: <<-EOS,
@summary Manages local MinIO S3 buckets
@example
  minio_bucket { 'my-bucket':
    ensure => 'present',
  }

**Autorequires**:
* `File[/root/.minioclient]`
* `Minio_client_alias[puppet]`
EOS
  features: [],
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
  },
)
