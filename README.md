# puppet-minio

[![Build Status][build-shield]][build-status]
[![Puppet Forge][forge-shield]][forge-minio]
[![Puppet Forge - downloads][forge-shield-dl]][forge-minio]
[![Puppet Forge - scores][forge-shield-sc]][forge-minio]

## Description

A Puppet module for managing [Minio][minio] (Amazon S3 compatible storage)
settings.

This module allows you to install and configure Minio using pre-built binaries
and does not need external package repositories. You can chose to install Minio
with default settings, or customize all settings to your liking.

## Setup

### What Minio affects

- `puppet-minio` depends on
  - [puppetlabs-stdlib][puppetlabs-stdlib],
  - [puppet-archive][puppet-archive],
  - [puppet-certs][puppet-certs]
- it manages a user and group `minio`
- it manages the Minio directory (`/opt/minio`) and the storage (`/var/minio`)
- it installs a `minio` service listening on port `9000`

### Beginning with Minio

The simplest use case is to rely on defaults. This can be done by simply
including the class:

```puppet
include ::minio
```

## Reference

See [REFERENCE.md](REFERENCE.md) for the full reference.

## Configuration

In addition to standard [minio server environment variables][minio-environment-variables],
there are the following ones:

* `MINIO_OPTS` - used to specify additional command-line arguments for the minio server.
  Example: `"--quiet --anonymous"` (with quotes)

* `MINIO_DEPLOYMENT_DEFINITION` - used to specify custom deployment definition.
  Required for erasure coding and distributed mode. Not required if used with
  a single storage root.
  Examples:

  * `/var/minio{1...4}` - for erasure coding
  * `https://server{1...4}/var/minio{1...4} https://server{4...8}/var/minio{1...4}` - for distributed deployments
  * `/var/minio` - for standalone deployment without erasure coding. Will be the default value
    if `storage_root` is `/var/minio` or `['/var/minio']`.

### Class: `minio`

```puppet
class { 'minio':
    package_ensure                => 'present',
    owner                         => 'minio',
    group                         => 'minio',
    base_url                      => 'https://dl.minio.io/server/minio/release',
    version                       => 'RELEASE.2021-08-20T18-32-01Z',
    checksum                      => '0bf72d6fd0a88fee35ac598a1e7a5c90c78b53b6db3988414e34535fb6cf420c',
    checksum_type                 => 'sha256',
    configuration_directory       => '/etc/minio',
    installation_directory        => '/opt/minio',
    storage_root                  => '/var/minio', # Could also be an array
    listen_ip                     => '127.0.0.1',
    listen_port                   => 9000,
    configuration                 => {
        'MINIO_ROOT_USER'             => 'admin',
        'MINIO_ROOT_PASSWORD'         => 'password',
        'MINIO_REGION_NAME'           => 'us-east-1',
        'MINIO_OPTS'                  => '"--quiet --anonymous"',
        'MINIO_DEPLOYMENT_DEFINITION' => 'https://example{1..4}.com/var/minio{1...4} https://example{5..8}.com/var/minio{1...4}'
    },
    manage_service                => true,
    service_template              => 'minio/systemd.erb',
    service_provider              => 'systemd',
    service_ensure                => 'running',
    manage_server_installation    => true,
    manage_client_installation    => true,
    client_package_ensure         => 'present',
    client_base_url               => 'https://dl.minio.io/client/mc/release',
    client_version                => 'RELEASE.2021-07-27T06-46-19Z',
    client_checksum               => '0df81285771e12e16a0c4c2f5e0ebc700e66abb8179013cc740d48b0abad49be',
    client_checksum_type          => 'sha256',
    client_installation_directory => '/opt/minioclient',
    cert_ensure                   => 'present',
    cert_directory                => '/etc/minio/certs',
    default_cert_configuration    => {
        'source_path'      => 'puppet:///modules/minio/examples',
        'source_cert_name' => 'localhost',
        'source_key_name'  => 'localhost',
    },
    additional_certs              => {
        'example' => {
            'source_path'      => 'puppet:///modules/minio/examples',
            'source_cert_name' => 'example.test',
            'source_key_name'  => 'example.test',
        }
    },
}
```

### Class: `minio::server`

```puppet
class { 'minio::server':
    manage_server_installation => true,
    package_ensure             => 'present',
    owner                      => 'minio',
    group                      => 'minio',
    base_url                   => 'https://dl.minio.io/server/minio/release',
    version                    => 'RELEASE.2021-08-20T18-32-01Z',
    checksum                   => '0bf72d6fd0a88fee35ac598a1e7a5c90c78b53b6db3988414e34535fb6cf420c',
    checksum_type              => 'sha256',
    configuration_directory    => '/etc/minio',
    installation_directory     => '/opt/minio',
    storage_root               => '/var/minio', # Could also be an array
    listen_ip                  => '127.0.0.1',
    listen_port                => 9000,
    configuration              => {
        'MINIO_ROOT_USER'             => 'admin',
        'MINIO_ROOT_PASSWORD'         => 'password',
        'MINIO_REGION_NAME'           => 'us-east-1',
        'MINIO_OPTS'                  => '"--quiet --anonymous"',
        'MINIO_DEPLOYMENT_DEFINITION' => 'https://example{1..4}.com/var/minio{1...4} https://example{5..8}.com/var/minio{1...4}'
    },
    manage_service             => true,
    service_template           => 'minio/systemd.erb',
    service_provider           => 'systemd',
    service_ensure             => 'running',
    cert_ensure                => 'present',
    cert_directory             => '/etc/minio/certs',
    default_cert_configuration => {
        'source_path'      => 'puppet:///modules/minio/examples',
        'source_cert_name' => 'localhost',
        'source_key_name'  => 'localhost',
    },
    additional_certs           => {
        'example' => {
            'source_path'      => 'puppet:///modules/minio/examples',
            'source_cert_name' => 'example.test',
            'source_key_name'  => 'example.test',
        }
    },
}
```

### Class: `minio::client`

```puppet
class { 'minio::client':
    manage_client_installation => true,
    package_ensure             => 'present',
    base_url                   => 'https://dl.minio.io/client/mc/release',
    version                    => 'RELEASE.2021-07-27T06-46-19Z',
    checksum                   => '0df81285771e12e16a0c4c2f5e0ebc700e66abb8179013cc740d48b0abad49be',
    checksum_type              => 'sha256',
    installation_directory     => '/usr/local/bin',
    binary_name                => 'minio-client',
    aliases                    => {
        'default' => {
            'ensure'              => 'present',
            'endpoint'            => 'http://localhost:9000',
            'access_key'          => 'admin',
            'secret_key'          => Sensitive('password'), # can also be a string
            'api_signature'       => 'S3v4', # optional
            'path_lookup_support' => 'on',   # optional
        }
    },
    purge_unmanaged_aliases    => true
}
```

## Limitations

See [metadata.json](metadata.json) for supported platforms.

* It's currently not possible to purge unmanaged client aliases in the same run
  when the client is being installed.

## Development

### Running tests

This project contains tests for [rspec-puppet][puppet-rspec].

Quickstart:

```console
pdk bundle install
pdk bundle exec rake 'litmus:provision_list[puppet6]'
pdk bundle exec rake 'litmus:install_agent[puppet6]'
pdk bundle exec rake litmus:install_module
pdk bundle exec rake litmus:acceptance:parallel
pdk bundle exec rake litmus:tear_down
```

When submitting pull requests, please make sure that module documentation,
test cases and syntax checks pass.

[minio]: https://minio.io
[minio-environment-variables]: https://docs.min.io/minio/baremetal/reference/minio-server/minio-server.html#minio-server-environment-variables
[puppetlabs-stdlib]: https://github.com/puppetlabs/puppetlabs-stdlib
[puppet-archive]: https://github.com/voxpupuli/puppet-archive
[puppet-certs]: https://github.com/broadinstitute/puppet-certs
[puppet-rspec]: http://rspec-puppet.com/

[build-status]: https://travis-ci.org/kogitoapp/puppet-minio
[build-shield]: https://travis-ci.org/kogitoapp/puppet-minio.png?branch=master
[forge-minio]: https://forge.puppetlabs.com/kogitoapp/minio
[forge-shield]: https://img.shields.io/puppetforge/v/kogitoapp/minio.svg
[forge-shield-dl]: https://img.shields.io/puppetforge/dt/kogitoapp/minio.svg
[forge-shield-sc]: https://img.shields.io/puppetforge/f/kogitoapp/minio.svg
