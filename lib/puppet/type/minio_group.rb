# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'minio_group',
  docs: <<-EOS,
@summary Manages local MinIO groups
@example
  minio_group { 'admins':
    ensure   => 'present',
    members  => ['userOne', 'userTwo'],
    policies => ['consoleAdmin'],
  }
@example
  minio_group { 'my-group':
    ensure   => 'present',
    members  => ['userThree', 'userFour'],
    policies => ['custom-policy'],
  }

**Autorequires**:
* `File[/root/.minioclient]`
* `File[/root/.minio_default_alias]`
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
    members: {
      type: 'Array[String, 1]',
      desc: 'List of users that should be part of this group.',
    },
    enabled: {
      type: 'Optional[Boolean]',
      desc: 'Set to false to disable this group. Defaults to true.',
      default: true,
    },
    policies: {
      type: 'Optional[Array[String]]',
      desc: 'List of MinIO PBAC policies to set for this group.',
    },
  },
)
