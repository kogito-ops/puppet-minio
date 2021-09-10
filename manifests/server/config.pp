# @summary
#   Applies configuration for `::minio::server` class to system.
#
# @example
#  class { 'minio::server::config':
#      owner                          => 'minio',
#      group                          => 'minio',
#      configuration_directory        => '/etc/minio',
#      installation_directory         => '/opt/minio',
#      storage_root                   => '/var/minio',
#      configuration                  => {
#          'MINIO_ROOT_USER'     => 'admin',
#          'MINIO_ROOT_PASSWORD' => 'password',
#          'MINIO_REGION_NAME'   => 'us-east-1',
#      },
#      custom_configuration_file_path => '/etc/default/minio',
#  }
#
# @param [String] owner
#   The user owning minio and its' files.
# @param [String] group
#   The group owning minio and its' files.
# @param [Stdlib::Absolutepath] configuration_directory
#   Directory holding Minio configuration file./minio`
# @param [Stdlib::Absolutepath] installation_directory
#   Target directory to hold the minio installation./minio`
# @param [Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]]] storage_root
#   Directory or directories where minio will keep all data.
# @param [Hash[String[1], Variant[String, Integer]]] configuration
#   Hash with environment settings for Minio.
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
class minio::server::config (
  Hash[String[1], Variant[String, Integer]] $configuration = $minio::server::configuration,
  String $owner = $minio::server::owner,
  String $group = $minio::server::group,
  Stdlib::Absolutepath $configuration_directory = $minio::server::configuration_directory,
  Stdlib::Absolutepath $installation_directory = $minio::server::installation_directory,
  Variant[Stdlib::Absolutepath, Array[Stdlib::Absolutepath]] $storage_root = $minio::server::storage_root,
  Optional[Stdlib::Absolutepath] $custom_configuration_file_path = $minio::server::custom_configuration_file_path,
  ) {

  $storage = [$storage_root].flatten()
  if ($storage.length() > 1 and !has_key($configuration, 'MINIO_DEPLOYMENT_DEFINITION')) {
    fail('Please provide a value for the MINIO_DEPLOYMENT_DEFINITION in configuration to run distributed or erasure-coded deployment.')
  }

  $configuration_file_path = pick($custom_configuration_file_path, "${configuration_directory}/config")

  $default_configuration = {
    'MINIO_ROOT_USER'             => 'admin',
    'MINIO_ROOT_PASSWORD'         => 'password',
    'MINIO_REGION_NAME'           => 'us-east-1',
    'MINIO_DEPLOYMENT_DEFINITION' => $storage[0],
  }

  $resulting_configuration = deep_merge($default_configuration, $configuration)

  file { $configuration_file_path:
    content => template('minio/config.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
  }
}
