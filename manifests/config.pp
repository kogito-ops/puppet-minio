# Class: minio::config
# ===========================
#
# Applies configuration for `::minio` class to system.
#
# Parameters
# ----------
#
# * `configuration`
# INI style settings for configuring Minio.
#
# * `owner`
# The user owning minio and its' files. Default: 'minio'
#
# * `group`
# The group owning minio and its' files. Default: 'minio'
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
class minio::config (
  $configuration           = $minio::configuration,
  $owner                   = $minio::owner,
  $group                   = $minio::group,
  $configuration_directory = $minio::configuration_directory,
  $installation_directory  = $minio::installation_directory,
  $storage_root            = $minio::storage_root,
  $log_directory           = $minio::log_directory,
  ) {

  $default_configuration = {}

  $resulting_configuration = deep_merge($default_configuration, $configuration)
}
