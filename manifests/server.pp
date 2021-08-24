# @summary
#   Manages a Minio server installation on various Linux/BSD operating systems.
#
# @example
#   class { 'minio::server':
#       package_ensure          => 'present',
#       owner                   => 'minio',
#       group                   => 'minio',
#       base_url                => 'https://dl.minio.io/server/minio/release',
#       version                 => 'RELEASE.2021-08-20T18-32-01Z',
#       checksum                => '0bf72d6fd0a88fee35ac598a1e7a5c90c78b53b6db3988414e34535fb6cf420c',
#       checksum_type           => 'sha256',
#       configuration_directory => '/etc/minio',
#       installation_directory  => '/opt/minio',
#       storage_root            => '/var/minio',
#       listen_ip               => '127.0.0.1',
#       listen_port             => 9000,
#       configuration           => {
#           'MINIO_ACCESS_KEY'  => 'admin',
#           'MINIO_SECRET_KEY'  => 'password',
#           'MINIO_REGION_NAME' => 'us-east-1',
#       },
#       manage_service          => true,
#       service_template        => 'minio/systemd.erb',
#       service_provider        => 'systemd',
#       service_ensure          => 'running',
#   }
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
# @param [Stdlib::Absolutepath] storage_root
#   Directory where minio will keep all data./minio`
# @param [Stdlib::IP::Address] listen_ip
#   IP address on which Minio should listen to requests.
# @param [Stdlib::Port] listen_port
#   Port on which Minio should listen to requests.
# @param [Hash[String[1], Variant[String, Integer]]] configuration
#   Hash with environment settings for Minio.
# @param [Boolean] manage_service
#   Should we manage a server service definition for Minio?
# @param [Stdlib::Ensure::Service] service_ensure
#   Defines the state of the minio server service.
# @param [String] service_template
#   Path to the server service template file.
# @param [String] service_provider
#   Which service provider do we use?
#
# @author Daniel S. Reichenbach <daniel@kogitoapp.com>
# @author Evgeny Soynov <esoynov@kogito.network>
#
# Copyright
# ---------
#
# Copyright 2017-2021 Daniel S. Reichenbach <https://kogitoapp.com>
#
class minio::server (
  Enum['present', 'absent'] $package_ensure = $minio::package_ensure,

  String $owner = $minio::owner,
  String $group = $minio::group,

  Stdlib::HTTPUrl $base_url = $minio::base_url,
  String $version = $minio::version,
  String $checksum = $minio::checksum,
  String $checksum_type = $minio::checksum_type,
  Stdlib::Absolutepath $configuration_directory = $minio::configuration_directory,
  Stdlib::Absolutepath $installation_directory = $minio::installation_directory,
  Stdlib::Absolutepath $storage_root = $minio::storage_root,
  Stdlib::IP::Address $listen_ip = $minio::listen_ip,
  Stdlib::Port $listen_port = $minio::listen_port,

  Hash[String[1], Variant[String, Integer]] $configuration = $minio::configuration,

  Boolean $manage_service = $minio::manage_service,
  Stdlib::Ensure::Service $service_ensure = $minio::service_ensure,
  String $service_template = $minio::service_template,
  String $service_provider = $minio::service_provider,
  ) {

  include ::minio::server::install
  include ::minio::server::config
  include ::minio::server::service

  Class['minio::server::install']
  -> Class['minio::server::config']
  ~> Class['minio::server::service']
}
