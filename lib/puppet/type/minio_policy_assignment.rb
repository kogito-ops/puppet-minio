# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'minio_policy_assignment',
  docs: <<-EOS,
@summary Assigns MinIO policies to users or groups
@example
minio_policy_assignment { 'test':
  ensure => 'present',
}

**Autorequires**:
* `File[/root/.minioclient]`
* `File[/root/.minio_default_alias]`
EOS
  features: [],
  title_patterns: [
    {
      pattern: %r{^(?<subject_type>.*)_(?<subject>.*)$},
      desc: 'Subject type and subject are both provided with a hyphen seperator',
    },
  ],
  attributes: {
    ensure: {
      type:    'Enum[present, absent]',
      desc:    'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    subject_type: {
      type:      'Enum[user, group]',
      desc:      'The type of subject to assign policie to. Should be user or group.',
      behaviour: :namevar,
    },
    subject: {
      type:      'String',
      desc:      'The user or group to assign policies to.',
      behaviour: :namevar,
    },
    policies: {
      type: 'Array[String]',
      desc: 'List of policies to assign to the subject.',
    },
  },
)
