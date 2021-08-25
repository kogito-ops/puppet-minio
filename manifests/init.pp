# @summary
#   Manages a Minio installation on various Linux/BSD operating systems.
#
# @example
#   class { 'minio':
#       package_ensure                => 'present',
#       owner                         => 'minio',
#       group                         => 'minio',
#       base_url                      => 'https://dl.minio.io/server/minio/release',
#       version                       => 'RELEASE.2021-08-20T18-32-01Z',
#       checksum                      => '0bf72d6fd0a88fee35ac598a1e7a5c90c78b53b6db3988414e34535fb6cf420c',
#       checksum_type                 => 'sha256',
#       configuration_directory       => '/etc/minio',
#       installation_directory        => '/opt/minio',
#       storage_root                  => '/var/minio',
#       listen_ip                     => '127.0.0.1',
#       listen_port                   => 9000,
#       configuration                 => {
#           'MINIO_ACCESS_KEY'  => 'admin',
#           'MINIO_SECRET_KEY'  => 'password',
#           'MINIO_REGION_NAME' => 'us-east-1',
#       },
#       manage_service                => true,
#       service_template              => 'minio/systemd.erb',
#       service_provider              => 'systemd',
#       service_ensure                => 'running',
#       manage_server_installation    => true,
#       manage_client_installation    => true,
#       client_package_ensure         => 'present',
#       client_base_url               => 'https://dl.minio.io/client/mc/release',
#       client_version                => 'RELEASE.2021-07-27T06-46-19Z',
#       client_checksum               => '0df81285771e12e16a0c4c2f5e0ebc700e66abb8179013cc740d48b0abad49be',
#       client_checksum_type          => 'sha256',
#       client_installation_directory => '/opt/minioclient',
#   }
#
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
# @param [Optional[Stdlib::Absolutepath]] home
#   Qualified path to the users' home directory. Default: empty
# @param [Stdlib::HTTPUrl] base_url
#   Download base URL for the server. Default: Github. Can be used for local mirrors.
# @param [String] version
#   Server release version to be installed.
# @param [String] checksum
#   Checksum for the server binary.
# @param [String] checksum_type
#   Type of checksum used to verify the server binary being installed. Default: `sha256`
# @param [Stdlib::Absolutepath] configuration_directory
#   Directory holding Minio configuration file. Default: `/etc/minio`
# @param [Stdlib::Absolutepath] installation_directory
#   Target directory to hold the minio installation. Default: `/opt/minio`
# @param [Stdlib::Absolutepath] storage_root
#   Directory where minio will keep all data. Default: `/var/minio`
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
# @param [Boolean] manage_server_installation
#   Decides if puppet should manage the minio server installation.
# @param [Boolean] manage_client_installation
#   Decides if puppet should manage the minio client installation.
# @param [Enum['present', 'absent']] client_package_ensure
#   Decides if the `mc` client binary will be installed. Default: `present`
# @param [Stdlib::HTTPUrl] client_base_url
#   Download base URL for the minio client. Default: Github. Can be used for local mirrors.
# @param [String] client_version
#   Client release version to be installed.
# @param [String] client_checksum
#   Checksum for the client binary.
# @param [String] client_checksum_type
#   Type of checksum used to verify the client binary being installed. Default: `sha256`
# @param [Stdlib::Absolutepath] client_installation_directory
#   Target directory to hold the minio client installation. Default: `/opt/minioclient`
#
# @author Daniel S. Reichenbach <daniel@kogitoapp.com>
# @author Evgeny Soynov <esoynov@kogito.network>
#
# Copyright
# ---------
#
# Copyright 2017-2021 Daniel S. Reichenbach <https://kogitoapp.com>
#
class minio (
  Enum['present', 'absent'] $package_ensure,

  Boolean $manage_user,
  Boolean $manage_group,
  Boolean $manage_home,
  String $owner,
  String $group,
  Optional[Stdlib::Absolutepath] $home,

  Stdlib::HTTPUrl $base_url,
  String $version,
  String $checksum,
  String $checksum_type,
  Stdlib::Absolutepath $configuration_directory,
  Stdlib::Absolutepath $installation_directory,
  Stdlib::Absolutepath $storage_root,
  Stdlib::IP::Address $listen_ip,
  Stdlib::Port $listen_port,

  Hash[String[1], Variant[String, Integer]] $configuration,

  Boolean $manage_service,
  Stdlib::Ensure::Service $service_ensure,
  String $service_template,
  String $service_provider,

  Boolean $manage_server_installation,
  Boolean $manage_client_installation,
  Enum['present', 'absent'] $client_package_ensure,
  Stdlib::HTTPUrl $client_base_url,
  String $client_version,
  String $client_checksum,
  String $client_checksum_type,
  Stdlib::Absolutepath $client_installation_directory,
  ) {

  include ::minio::server
  include ::minio::client

  Class['minio::server'] -> Class['minio::client']
}
