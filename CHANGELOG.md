# Changelog

All notable changes to this project will be documented in this file.

## Release 1.1.0 (2017-11-15)

With this release, ownership of this module is transfered to Kogito UG,
a DevOps / Infrastructure services business in Berlin, Germany.

**Features**

- Upgrade default Minio installation to a more recent version
- Base URL for Minio downloads can now be pointed to a custom location
- Converted module to be Puppet Development Kit compatible
- Added support for Debian 9 (Stretch)
- Updated Puppet requirements to be in line with PE lifecycle
- **API**: `sorted_json(...)` function has been converted to a Puppet 4 style
  function and renamed to `to_sorted_json(...)`

## Release 1.0.2 (2017-07-13)

**Features**

- Switched to using proper resource types in all places

## Release 1.0.1 (2017-05-09)

**Features**

- Added support to configure service address and port

**Bugfixes**

- Updated install function to use release archives for a stable source

## Release 1.0.0 (2017-05-08)

Initial release of [Minio](https://minio.io) management module. Hello, World!
