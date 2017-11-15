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
  - [lwf-remote_file][lwf-remote_file],
- it manages a user and group `minio`
- it manages the Minio directory (`/opt/minio`) and the storage (`/var/minio`)
- it install a `minio` service listening on port `3000`

### Beginning with Minio

The simplest use case is to rely on defaults. This can be done by simply
including the class:

```puppet
include ::minio
```

## Reference

### Class: `minio`

```puppet
class { 'minio':
    package_ensure => 'present',
    manage_user => true,
    manage_group => true,
    manage_home => true,
    owner => 'minio',
    group => 'minio',
    home => '/home/minio',
    version => 'RELEASE.2017-05-05T01-14-51Z',
    checksum => '59cd3fb52292712bd374a215613d6588122d93ab19d812b8393786172b51d556',
    checksum_type => 'sha256',
    configuration_directory => '/etc/minio',
    installation_directory => '/opt/minio',
    storage_root => '/var/minio',
    log_directory => '/var/log/minio',
    listen_ip => '127.0.0.1',
    listen_port => '9000',
    configuration => {
        'credential' => {
          'accessKey' => 'ADMIN',
          'secretKey' => 'PASSWORD',
        },
        'region' => 'us-east-1',
        'browser' => 'on',
    },
    manage_service => true,
    service_template => 'minio/systemd.erb',
    service_path => '/lib/systemd/system/minio.service',
    service_provider => 'systemd',
    service_mode => '0644',
}
```

### Class: `minio::user`

```puppet
class { 'minio::user':
    manage_user => true,
    manage_group => true,
    manage_home => true,
    owner => 'minio',
    group => 'minio',
    home => '/home/minio',
}
```

### Class: `minio::install`

```puppet
class { 'minio::install':
    package_ensure => 'present',
    owner => 'minio',
    group => 'minio',
    version => 'RELEASE.2017-05-05T01-14-51Z',
    checksum => '59cd3fb52292712bd374a215613d6588122d93ab19d812b8393786172b51d556',
    checksum_type => 'sha256',
    installation_directory => '/opt/minio',
    storage_root => '/var/minio',
    log_directory => '/var/log/minio',
    listen_ip => '127.0.0.1',
    listen_port => '9000',
    manage_service => true,
    service_template => 'minio/systemd.erb',
    service_path => '/lib/systemd/system/minio.service',
    service_provider => 'systemd',
    service_mode => '0644',
}
```

### Class: `minio::service`

```puppet
class { 'minio::service':
    manage_service => true,
    service_provider => 'systemd',
}
```

### Class: `minio::config`

```puppet
class { 'minio::config':
    configuration => {
        'credential' => {
          'accessKey' => 'ADMIN',
          'secretKey' => 'PASSWORD',
        },
        'region' => 'us-east-1',
        'browser' => 'on',
    },
    owner => 'minio',
    group => 'minio',
    installation_directory => '/opt/minio',
    storage_root => '/var/minio',
    log_directory => '/var/log/minio',
}
```

## Limitations

See [metadata.json](metadata.json) for supported platforms.

## Development

### Running tests

This project contains tests for [rspec-puppet][puppet-rspec].

Quickstart:

```bash
gem install bundler
bundle install
bundle exec rake test
```

When submitting pull requests, please make sure that module documentation,
test cases and syntax checks pass.

[minio]: https://minio.io
[puppetlabs-stdlib]: https://github.com/puppetlabs/puppetlabs-stdlib
[lwf-remote_file]: https://github.com/lwf/puppet-remote_file
[puppet-rspec]: http://rspec-puppet.com/

[build-status]: https://travis-ci.org/kogitoapp/puppet-minio
[build-shield]: https://travis-ci.org/kogitoapp/puppet-minio.png?branch=master
[forge-minio]: https://forge.puppetlabs.com/kogitoapp/minio
[forge-shield]: https://img.shields.io/puppetforge/v/kogitoapp/minio.svg
[forge-shield-dl]: https://img.shields.io/puppetforge/dt/kogitoapp/minio.svg
[forge-shield-sc]: https://img.shields.io/puppetforge/f/kogitoapp/minio.svg
