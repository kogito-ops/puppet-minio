# @summary
#   Manages a Minio server installation on various Linux/BSD operating systems.
#
# @example
#  class { 'minio::server':
#      manage_server_installation     => true,
#      package_ensure                 => 'present',
#      owner                          => 'minio',
#      group                          => 'minio',
#      base_url                       => 'https://dl.minio.io/server/minio/release',
#      version                        => 'RELEASE.2021-08-20T18-32-01Z',
#      checksum                       => '0bf72d6fd0a88fee35ac598a1e7a5c90c78b53b6db3988414e34535fb6cf420c',
#      checksum_type                  => 'sha256',
#      configuration_directory        => '/etc/minio',
#      installation_directory         => '/opt/minio',
#      storage_root                   => '/var/minio', # Could also be an array
#      listen_ip                      => '127.0.0.1',
#      listen_port                    => 9000,
#      configuration                  => {
#          'MINIO_ROOT_USER'     => 'admin',
#          'MINIO_ROOT_PASSWORD' => 'password',
#          'MINIO_REGION_NAME'   => 'us-east-1',
#      },
#      manage_service                 => true,
#      service_template               => 'minio/systemd.erb',
#      service_provider               => 'systemd',
#      service_ensure                 => 'running',
#      cert_ensure                    => 'present',
#      cert_directory                 => '/etc/minio/certs',
#      default_cert_name              => 'miniodefault',
#      default_cert_configuration     => {
#        'source_path'      => 'puppet:///modules/minio/examples',
#        'source_cert_name' => 'localhost',
#        'source_key_name'  => 'localhost',
#      },
#      additional_certs               => {
#        'example' => {
#          'source_path'      => 'puppet:///modules/minio/examples',
#          'source_cert_name' => 'example.test',
#          'source_key_name'  => 'example.test',
#        }
#      },
#      custom_configuration_file_path => '/etc/default/minio',
#  }
#
# @param [Boolean] manage_server_installation
#   Decides if puppet should manage the minio server installation.
# @param [Enum['present', 'absent']] package_ensure
#   Decides if the `minio` binary will be installed. Default: `present`
# @param [Boolean] manage_user
#   Should we manage provisioning the user? Default: `true`
# @param [Boolean] manage_group
#   Should we manage provisioning the group? Default: `true`
# @param [Boolean] manage_home
#   Should we manage provisioning the home directory? Default: `true`
# @param [String] owner
#   The user owning minio and its' files. Default: 'minio'
# @param [String] group
#   The group owning minio and its' files. Default: 'minio'
# @param [Stdlib::HTTPUrl] base_url
#   Download base URL for the server. Can be used for local mirrors.
# @param [Optional[Stdlib::Absolutepath]] home
#   Qualified path to the users' home directory. Default: empty
# @param [Stdlib::HTTPUrl] base_url
#   Download base URL for the server. Default: Github. Can be used for local mirrors.
# @param [String] version
#   Release version to be installed.
# @param [String] checksum
#   Checksum for the binary.
# @param [String] checksum_type
#   Type of checksum used to verify the binary being installed. Default: `sha256`
# @param [Stdlib::Absolutepath] configuration_directory
#   Directory holding Minio configuration file. Default: `/etc/minio`
# @param [Stdlib::Absolutepath] installation_directory
#   Target directory to hold the minio installation. Default: `/opt/minio`
# @param [Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]]] storage_root
#   Directory or directories where minio will keep all data. Default: `/var/minio`
# @param [Stdlib::IP::Address] listen_ip
#   IP address on which Minio should listen to requests.
# @param [Stdlib::Port] listen_port
#   Port on which Minio should listen to requests.
# @param [Hash[String[1], Variant[String, Integer]]] configuration
#   Hash with environment settings for Minio.
# @param [Boolean] manage_service
#   Should we manage a server service definition for Minio? Default: `true`
# @param [Stdlib::Ensure::Service] service_ensure
#   Defines the state of the minio server service. Default: `running`
# @param [String] service_template
#   Path to the server service template file.
# @param [String] service_provider
#   Which service provider do we use?
# @param [Enum['present', 'absent']] cert_ensure
#   Decides if minio certificates binary will be installed.
# @param [Stdlib::Absolutepath] cert_directory
#   Directory where minio will keep all cerfiticates.
# @param [Optional[String[1]]] default_cert_name
#   Name of the default certificate. If no value provided, `miniodefault` is going
#   to be used.
# @param [Optional[Hash]] default_cert_configuration
#   Hash with the configuration for the default certificate. See `certs::site`
#   of the `broadinstitute/certs` module for parameter descriptions.
# @param [Optional[Hash]] additional_certs
#   Hash of the additional certificates to deploy. The key is a directory name, value is
#   a hash of certificate configuration. See `certs::site` of the `broadinstitute/certs`
#   module for parameter descriptions. **Important**: if you use additional certificates,
#   their corresponding SAN names should be filled for SNI to work.
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
class minio::server (
  Boolean $manage_server_installation = $minio::manage_server_installation,
  Enum['present', 'absent'] $package_ensure = $minio::package_ensure,

  Boolean $manage_user = $minio::manage_user,
  Boolean $manage_group = $minio::manage_group,
  Boolean $manage_home = $minio::manage_home,
  Optional[Stdlib::Absolutepath] $home = $minio::home,
  String $owner = $minio::owner,
  String $group = $minio::group,

  Stdlib::HTTPUrl $base_url = $minio::base_url,
  String $version = $minio::version,
  String $checksum = $minio::checksum,
  String $checksum_type = $minio::checksum_type,
  Stdlib::Absolutepath $configuration_directory = $minio::configuration_directory,
  Stdlib::Absolutepath $installation_directory = $minio::installation_directory,
  Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]] $storage_root = $minio::storage_root,
  Stdlib::IP::Address $listen_ip = $minio::listen_ip,
  Stdlib::Port $listen_port = $minio::listen_port,

  Hash[String[1], Variant[String, Integer]] $configuration = $minio::configuration,

  Boolean $manage_service = $minio::manage_service,
  Stdlib::Ensure::Service $service_ensure = $minio::service_ensure,
  String $service_template = $minio::service_template,
  String $service_provider = $minio::service_provider,
  Enum['present', 'absent'] $cert_ensure = $minio::cert_ensure,
  Stdlib::Absolutepath $cert_directory = $minio::cert_directory,
  Optional[String[1]] $default_cert_name = $minio::default_cert_name,
  Optional[Hash] $default_cert_configuration = $minio::default_cert_configuration,
  Optional[Hash] $additional_certs = $minio::additional_certs,
  Optional[Stdlib::Absolutepath] $custom_configuration_file_path = $minio::custom_configuration_file_path,
) {
  if ($manage_server_installation) {
    include ::minio::server::user
    include ::minio::server::install
    include ::minio::server::config
    include ::minio::server::certs
    include ::minio::server::service

    Class['minio::server::user']
    -> Class['minio::server::install']
    -> Class['minio::server::config']
    -> Class['minio::server::certs']
    -> Class['minio::server::service']

    Class['minio::server::install', 'minio::server::config', 'minio::server::certs'] ~> Class['minio::server::service']
  }
}
