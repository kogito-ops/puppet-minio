# Class: minio::install
# ===========================
#
# Installs minio, and sets up the directory structure required to run Minio.
#
# Parameters
# ----------
#
# * `package_ensure`
# Decides if the `minio` binary will be installed. Default: 'present'
#
# * `owner`
# The user owning minio and its' files. Default: 'minio'
#
# * `group`
# The group owning minio and its' files. Default: 'minio'
#
# * `base_url`
# Download base URL. Default: Github. Can be used for local mirrors.
#
# * `version`
# Release version to be installed.
#
# * `checksum`
# Checksum for the binary.
# Default: '59cd3fb52292712bd374a215613d6588122d93ab19d812b8393786172b51d556'
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
# Directory where minio will keep all files. Default: '/var/minio'
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
class minio::install (
  Enum['present', 'absent'] $package_ensure = $minio::package_ensure,
  String $owner                   = $minio::owner,
  String $group                   = $minio::group,

  String $base_url                = $minio::base_url,
  String $version                 = $minio::version,
  String $checksum                = $minio::checksum,
  String $checksum_type           = $minio::checksum_type,
  String $configuration_directory = $minio::configuration_directory,
  String $installation_directory  = $minio::installation_directory,
  String $storage_root            = $minio::storage_root,
  String $log_directory           = $minio::log_directory,
  String $listen_ip               = $minio::listen_ip,
  Integer $listen_port            = $minio::listen_port,

  Boolean $manage_service         = $minio::manage_service,
  String $service_template        = $minio::service_template,
  String $service_path            = $minio::service_path,
  String $service_provider        = $minio::service_provider,
  String $service_mode            = $minio::service_mode,
  ) {

  file { $storage_root:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${storage_root}"],
  }

  -> file { $configuration_directory:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${configuration_directory}"],
  }

  -> file { $installation_directory:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${installation_directory}"],
  }

  -> file { $log_directory:
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    notify => Exec["permissions:${log_directory}"],
  }

  if ($package_ensure) {
    $kernel_down=downcase($::kernel)

    case $::architecture {
      /(x86_64)/: {
        $arch = 'amd64'
      }
      /(x86)/: {
        $arch = '386'
      }
      default: {
        $arch = $::architecture
      }
    }

    $source_url="${base_url}/${kernel_down}-${arch}/archive/minio.${version}"

    remote_file { 'minio':
      ensure        => $package_ensure,
      path          => "${installation_directory}/minio",
      source        => $source_url,
      checksum      => $checksum,
      checksum_type => $checksum_type,
      notify        => [
        Exec["permissions:${$installation_directory}/minio"],
        Service['minio']
      ],
    }
  }

  exec { "permissions:${configuration_directory}":
    command     => "chown -Rf ${owner}:${group} ${installation_directory}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${installation_directory}":
    command     => "chown -Rf ${owner}:${group} ${installation_directory}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${$installation_directory}/minio":
    command     => "chmod +x ${$installation_directory}/minio",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${storage_root}":
    command     => "chown -Rf ${owner}:${group} ${storage_root}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${log_directory}":
    command     => "chown -Rf ${owner}:${group} ${log_directory}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  if ($manage_service) {

    case $service_provider {
      'upstart': { $service_path = '/etc/init/minio.conf'; $service_template = 'minio/upstart.erb' }
      default:   {}
    }

    file { "service:${service_path}":
      path    => $service_path,
      content => template($service_template),
      mode    => $service_mode,
    }
  }
}
