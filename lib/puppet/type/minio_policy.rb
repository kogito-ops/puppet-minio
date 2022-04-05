# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'minio_policy',
  docs: <<-EOS,
@summary Manages local MinIO policies
@example
  minio_policy { 'custom-policy':
    ensure    => 'present',
    statement => [
      {
        'Effect'   => 'Allow',
        'Action'   => ['s3:ListBucket'],
        'Resource' => ['arn:aws:s3:::my-bucket']
      },
      {
        'Effect'   => 'Allow',
        'Action'   => ['s3:GetObject', 's3:PutObject'],
        'Resource' => ['arn:aws:s3:::my-bucket']
      }
    ],
  }

**Autorequires**:
* `File[/root/.minioclient]`
* `File[/root/.minio_default_alias]`
EOS
  features: ['canonicalize'],
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
    version: {
      type:      'String',
      desc:      'Specifies the language syntax rules that are to be used to process a policy.',
      behaviour: :read_only,
    },
    statement: {
      type: 'Array[Hash]',
      desc: 'List of statements describing the policy.',
    }
  },
)
