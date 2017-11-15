# Class: minio
# ===========================
#
# Manages a Minio installation on various Linux/BSD operating systems.
#
# Parameters
# ----------
#
# * `package_ensure`
# Decides if the `minio` binary will be installed. Default: 'present'
#
# * `manage_user`
# Should we manage provisioning the user? Default: true
#
# * `manage_group`
# Should we manage provisioning the group? Default: true
#
# * `manage_home`
# Should we manage provisioning the home directory? Default: true
#
# * `owner`
# The user owning minio and its' files. Default: 'minio'
#
# * `group`
# The group owning minio and its' files. Default: 'minio'
#
# * `home`
# Qualified path to the users' home directory. Default: empty
#
# * `base_url`
# Download base URL. Default: Github. Can be used for local mirrors.
#
# * `version`
# Release version to be installed.
#
# * `checksum`
# Checksum for the binary.
#
# * `checksum_type`
# Type of checksum used to verify the binary being installed. Default: 'sha256'
#
# * `configuration_directory`
# Directory holding Minio configuration file. Default: '/etc/minio'
#
# * `installation_directory`
# Target directory to hold the minio installation. Default: '/opt/minio'
#
# * `storage_root`
# Directory where minio will keep all data. Default: '/var/minio'
#
# * `log_directory`
# Log directory for minio. Default: '/var/log/minio'
#
# * `listen_ip`
# IP address on which Minio should listen to requests.
#
# * `listen_port`
# Port on which Minio should listen to requests.
#
# * `configuration`
# Hash style settings for configuring Minio.
#
# * `manage_service`
# Should we manage a service definition for Minio?
#
# * `service_template`
# Path to service template file.
#
# * `service_path`
# Where to create the service definition.
#
# * `service_provider`
# Which service provider do we use?
#
# * `service_mode`
# File mode for the created service definition.
#
# Examples
# --------
#
# @example
#    class { 'minio':
#    }
#
# Authors
# -------
#
# Daniel S. Reichenbach <daniel@kogitoapp.com>
#
# Copyright
# ---------
#
# Copyright 2017 Daniel S. Reichenbach <https://kogitoapp.com>
#
class minio (
  Enum['present', 'absent'] $package_ensure,

  Boolean $manage_user,
  Boolean $manage_group,
  Boolean $manage_home,
  String $owner,
  String $group,
  Optional[String] $home,

  String $base_url,
  String $version,
  String $checksum,
  String $checksum_type,
  String $configuration_directory,
  String $installation_directory,
  String $storage_root,
  String $log_directory,
  String $listen_ip,
  Integer $listen_port,

  Hash $configuration,

  Boolean $manage_service,
  String $service_template,
  String $service_path,
  String $service_provider,
  String $service_mode,
  ) {

  class { '::minio::user': }
  class { '::minio::install': }

  class { '::minio::config': }
  class { '::minio::service': }

  anchor { 'minio::begin': }
  anchor { 'minio::end': }

  Anchor['minio::begin']
  -> Class['minio::user']
  -> Class['minio::install']
  -> Class['minio::config']
  ~> Class['minio::service']
}
