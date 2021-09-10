# @summary
#   Installs minio server and required service definitions.
#
# @example
#  class { 'minio::server::install':
#      package_ensure                 => 'present',
#      owner                          => 'minio',
#      group                          => 'minio',
#      base_url                       => 'https://dl.minio.io/server/minio/release',
#      version                        => 'RELEASE.2021-08-20T18-32-01Z',
#      checksum                       => '0bf72d6fd0a88fee35ac598a1e7a5c90c78b53b6db3988414e34535fb6cf420c',
#      checksum_type                  => 'sha256',
#      configuration_directory        => '/etc/minio',
#      installation_directory         => '/opt/minio',
#      storage_root                   => '/var/minio',
#      listen_ip                      => '127.0.0.1',
#      listen_port                    => 9000,
#      manage_service                 => true,
#      service_template               => 'minio/systemd.erb',
#      service_provider               => 'systemd',
#      cert_directory                 => '/etc/minio/certs',
#      custom_configuration_file_path => '/etc/default/minio',
#  }
#
# @param [Enum['present', 'absent']] package_ensure
#   Decides if the `minio` binary will be installed.
# @param [String] owner
#   The user owning minio and its' files.
# @param [String] group
#   The group owning minio and its' files.
# @param [Stdlib::HTTPUrl] base_url
#   Download base URL for the server. Can be used for local mirrors.
# @param [String] version
#   Release version to be installed.
# @param [String] checksum
#   Checksum for the binary.
# @param [String] checksum_type
#   Type of checksum used to verify the binary being installed.
# @param [Stdlib::Absolutepath] configuration_directory
#   Directory holding Minio configuration file./minio`
# @param [Stdlib::Absolutepath] installation_directory
#   Target directory to hold the minio installation./minio`
# @param [Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]]] storage_root
#   Directory or directories where minio will keep all data.
# @param [Stdlib::IP::Address] listen_ip
#   IP address on which Minio should listen to requests.
# @param [Stdlib::Port] listen_port
#   Port on which Minio should listen to requests.
# @param [Boolean] manage_service
#   Should we manage a server service definition for Minio?
# @param [String] service_template
#   Path to the server service template file.
# @param [String] service_provider
#   Which service provider do we use?
# @param [Stdlib::Absolutepath] cert_directory
#   Directory where minio will keep all cerfiticates.
# @param [Optional[Stdlib::Absolutepath]] custom_configuration_file_path
#   Optional custom location of the minio environment file.
#
# @author Daniel S. Reichenbach <daniel@kogitoapp.com>
# @author Evgeny Soynov <esoynov@kogito.network>
#
# Copyright
# ---------
#
# Copyright 2017-2021 Daniel S. Reichenbach <https://kogitoapp.com>
#
class minio::server::install (
  Enum['present', 'absent']  $package_ensure                                = $minio::server::package_ensure,
  String $owner                                                             = $minio::server::owner,
  String $group                                                             = $minio::server::group,

  Stdlib::HTTPUrl $base_url                                                 = $minio::server::base_url,
  String $version                                                           = $minio::server::version,
  String $checksum                                                          = $minio::server::checksum,
  String $checksum_type                                                     = $minio::server::checksum_type,
  Stdlib::Absolutepath $configuration_directory                             = $minio::server::configuration_directory,
  Stdlib::Absolutepath $installation_directory                              = $minio::server::installation_directory,
  Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]] $storage_root  = $minio::server::storage_root,
  Stdlib::IP::Address $listen_ip                                            = $minio::server::listen_ip,
  Stdlib::Port $listen_port                                                 = $minio::server::listen_port,

  Boolean $manage_service                                                   = $minio::server::manage_service,
  String $service_template                                                  = $minio::server::service_template,
  String $service_provider                                                  = $minio::server::service_provider,
  Stdlib::Absolutepath $cert_directory                                      = $minio::server::cert_directory,
  Optional[Stdlib::Absolutepath] $custom_configuration_file_path            = $minio::server::custom_configuration_file_path,
  ) {

  $configuration_file_path = pick($custom_configuration_file_path, "${configuration_directory}/config")

  [$storage_root].flatten().each | $storage | {
    file { $storage:
      ensure => 'directory',
      owner  => $owner,
      group  => $group,
      notify => Exec["permissions:${storage}"],
      before => File[$configuration_directory],
    }

    exec { "permissions:${storage}":
      command     => "chown -Rf ${owner}:${group} ${storage}",
      path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
      refreshonly => true,
    }
  }

  file { $configuration_directory:
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

    archive::download { "${installation_directory}/minio":
      ensure        => present,
      checksum      => true,
      digest_string => $checksum,
      digest_type   => $checksum_type,
      url           => $source_url,
    }
    -> file {"${installation_directory}/minio":
      group => $group,
      mode  => '0744',
      owner => $owner,
    }
  }

  exec { "permissions:${configuration_directory}":
    command     => "chown -Rf ${owner}:${group} ${configuration_directory}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  exec { "permissions:${installation_directory}":
    command     => "chown -Rf ${owner}:${group} ${installation_directory}",
    path        => '/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    refreshonly => true,
  }

  if ($manage_service) {
    case $service_provider {
      'systemd': {
        ::systemd::unit_file { 'minio.service':
          content => template($service_template),
        }
      }
      default: {
        fail("Service provider ${service_provider} not supported")
      }
    }
  }
}
