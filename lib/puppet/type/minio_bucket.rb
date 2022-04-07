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
* `File[/root/.minio_default_alias]`
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
    region: {
      type:      'Optional[String]',
      desc:      'Region where to create the bucket.',
      behaviour: :init_only,
      default:   'us-east-1',
    },
    enable_object_lock: {
      type:   'Optional[Boolean]',
      desc:   'Enables/Disables S3 object locking.',
      default: false,
    }
  },
)
