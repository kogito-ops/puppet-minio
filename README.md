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

### Class: `minio`

```puppet
class { 'minio':
    package_ensure          => 'present',
    manage_user             => true,
    manage_group            => true,
    manage_home             => true,
    owner                   => 'minio',
    group                   => 'minio',
    home                    => '/home/minio',
    version                 => 'RELEASE.2021-08-20T18-32-01Z',
    checksum                => '0bf72d6fd0a88fee35ac598a1e7a5c90c78b53b6db3988414e34535fb6cf420c',
    checksum_type           => 'sha256',
    configuration_directory => '/etc/minio',
    installation_directory  => '/opt/minio',
    storage_root            => '/var/minio',
    listen_ip               => '127.0.0.1',
    listen_port             => 9000,
    configuration           => {
        'MINIO_ACCESS_KEY'  => 'admin',
        'MINIO_SECRET_KEY'  => 'password',
        'MINIO_REGION_NAME' => 'us-east-1',
    },
    manage_service          => true,
    service_template        => 'minio/systemd.erb',
    service_provider        => 'systemd',
}
```

### Class: `minio::server::user`

```puppet
class { 'minio::server::user':
    manage_user  => true,
    manage_group => true,
    manage_home  => true,
    owner        => 'minio',
    group        => 'minio',
    home         => '/home/minio',
}
```

### Class: `minio::server::install`

```puppet
class { 'minio::server::install':
    package_ensure          => 'present',
    owner                   => 'minio',
    group                   => 'minio',
    base_url                => 'https://dl.minio.io/server/minio/release',
    version                 => 'RELEASE.2017-05-05T01-14-51Z',
    checksum                => '59cd3fb52292712bd374a215613d6588122d93ab19d812b8393786172b51d556',
    checksum_type           => 'sha256',
    configuration_directory => '/etc/minio',
    installation_directory  => '/opt/minio',
    storage_root            => '/var/minio',
    listen_ip               => '127.0.0.1',
    listen_port             => 9000,
    manage_service          => true,
    service_template        => 'minio/systemd.erb',
    service_provider        => 'systemd',
}
```

### Class: `minio::server::service`

```puppet
class { 'minio::server::service':
    manage_service => true,
    service_provider => 'systemd',
    service_ensure => 'running',
}
```

### Class: `minio::server::config`

```puppet
class { 'minio::server::config':
    configuration          => {
        'MINIO_ACCESS_KEY'  => 'admin',
        'MINIO_SECRET_KEY'  => 'password',
        'MINIO_REGION_NAME' => 'us-east-1',
    },
    owner                  => 'minio',
    group                  => 'minio',
    installation_directory => '/opt/minio',
    storage_root           => '/var/minio',
}
```

## Limitations

See [metadata.json](metadata.json) for supported platforms.

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
[puppetlabs-stdlib]: https://github.com/puppetlabs/puppetlabs-stdlib
[puppet-archive]: https://github.com/voxpupuli/puppet-archive
[puppet-rspec]: http://rspec-puppet.com/

[build-status]: https://travis-ci.org/kogitoapp/puppet-minio
[build-shield]: https://travis-ci.org/kogitoapp/puppet-minio.png?branch=master
[forge-minio]: https://forge.puppetlabs.com/kogitoapp/minio
[forge-shield]: https://img.shields.io/puppetforge/v/kogitoapp/minio.svg
[forge-shield-dl]: https://img.shields.io/puppetforge/dt/kogitoapp/minio.svg
[forge-shield-sc]: https://img.shields.io/puppetforge/f/kogitoapp/minio.svg
