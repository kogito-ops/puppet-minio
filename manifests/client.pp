# @summary
#   Manages a Minio client (mc) on various Linux/BSD operating systems.
#
# @example
#   class { 'minio::client':
#       manage_client_installation => true,
#       package_ensure             => 'present',
#       base_url                   => 'https://dl.minio.io/client/mc/release',
#       version                    => 'RELEASE.2021-07-27T06-46-19Z',
#       checksum                   => '0df81285771e12e16a0c4c2f5e0ebc700e66abb8179013cc740d48b0abad49be',
#       checksum_type              => 'sha256',
#       installation_directory     => '/usr/local/bin',
#       binary_name                => 'minio-client',
#       aliases                    => {
#         'default' => {
#           'ensure'              => 'present',
#           'endpoint'            => 'http://localhost:9000',
#           'access_key'          => 'admin',
#           'secret_key'          => Sensitive('password'), # can also be a string
#           'api_signature'       => 'S3v4', # optional
#           'path_lookup_support' => 'on',   # optional
#         }
#       },
#       purge_unmanaged_aliases    => true
#   }
#
# @param [Boolean] manage_client_installation
#   Decides if puppet should manage the minio client installation.
# @param [Enum['present', 'absent']] package_ensure
#   Decides if the `mc` client binary will be installed. Default: `present`
# @param [Stdlib::HTTPUrl] base_url
#   Download base URL for the minio client. Default: Github. Can be used for local mirrors.
# @param [String] version
#   Client release version to be installed.
# @param [String] checksum
#   Checksum for the client binary.
# @param [String] checksum_type
#   Type of checksum used to verify the client binary being installed. Default: `sha256`
# @param [Stdlib::Absolutepath] installation_directory
#   Target directory to hold the minio client installation. Default: `/opt/minioclient`
# @param [Hash] aliases
#   List of aliases to add to the minio client configuration. For parameter description see `minio_client_alias`.
# @param [Boolean] purge_unmanaged_aliases
#   Decides if puppet should purge unmanaged minio client aliases
#
# @author Daniel S. Reichenbach <daniel@kogitoapp.com>
# @author Evgeny Soynov <esoynov@kogito.network>
#
class minio::client(
  Boolean $manage_client_installation                   = $minio::manage_client_installation,
  Enum['present', 'absent'] $package_ensure             = $minio::client_package_ensure,
  Stdlib::HTTPUrl $base_url                             = $minio::client_base_url,
  String $version                                       = $minio::client_version,
  String $checksum                                      = $minio::client_checksum,
  String $checksum_type                                 = $minio::client_checksum_type,
  Stdlib::Absolutepath $installation_directory          = $minio::client_installation_directory,
  String $binary_name                                   = $minio::client_binary_name,
  Hash $aliases                                         = $minio::client_aliases,
  Boolean $purge_unmanaged_aliases                      = $minio::purge_unmanaged_client_aliases,
) {
  if ($manage_client_installation) {
    include ::minio::client::install
    include ::minio::client::config

    Class['minio::client::install'] -> Class['minio::client::config']
  }
}
