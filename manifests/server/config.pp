# @summary
#   Applies configuration for `::minio::server` class to system.
#
# @example
#   class { 'minio::server::config':
#       owner                   => 'minio',
#       group                   => 'minio',
#       configuration_directory => '/etc/minio',
#       installation_directory  => '/opt/minio',
#       storage_root            => '/var/minio',
#       configuration           => {
#           'MINIO_ROOT_USER'     => 'admin',
#           'MINIO_ROOT_PASSWORD' => 'password',
#           'MINIO_REGION_NAME'   => 'us-east-1',
#       },
#   }
#
# @param [String] owner
#   The user owning minio and its' files.
# @param [String] group
#   The group owning minio and its' files.
# @param [Stdlib::Absolutepath] configuration_directory
#   Directory holding Minio configuration file./minio`
# @param [Stdlib::Absolutepath] installation_directory
#   Target directory to hold the minio installation./minio`
# @param [Stdlib::Absolutepath] storage_root
#   Directory where minio will keep all data./minio`
# @param [Hash[String[1], Variant[String, Integer]]] configuration
#   Hash with environment settings for Minio.
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
  Hash[String[1], Variant[String, Integer]]          $configuration                  = $minio::server::configuration,
  String                                             $owner                          = $minio::server::owner,
  String                                             $group                          = $minio::server::group,
  Stdlib::Absolutepath                               $configuration_directory        = $minio::server::configuration_directory,
  Stdlib::Absolutepath                               $installation_directory         = $minio::server::installation_directory,
  Stdlib::Absolutepath                               $storage_root                   = $minio::server::storage_root,
  Optional[String[1]]                                $custom_configuration_file_path = $minio::server::custom_configuration_file_path,
  ) {

  $configuration_file_path = pick($custom_configuration_file_path, "${configuration_directory}/config")


  $default_configuration = {
    'MINIO_ROOT_USER'     => 'admin',
    'MINIO_ROOT_PASSWORD' => 'password',
    'MINIO_REGION_NAME'   => 'us-east-1',
  }

  $resulting_configuration = deep_merge($default_configuration, $configuration)

  file { $configuration_file_path:
    content => template('minio/config.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0644',
  }
}
