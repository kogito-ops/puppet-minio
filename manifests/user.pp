# Class: minio::user
# ===========================
#
# Manages user for the `::minio` class.
#
# Parameters
# ----------
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
class minio::user (
  $manage_user  = $minio::manage_user,
  $manage_group = $minio::manage_group,
  $manage_home  = $minio::manage_home,
  $owner        = $minio::owner,
  $group        = $minio::group,
  $home         = $minio::home,
  ) {

  if ($manage_home) {
    if $home == undef {
      $homedir = "/home/${owner}"
    } else {
      $homedir = $home
    }
  }

  if ($manage_user) {
    group { $group:
      ensure => present,
      system => true,
    }
  }

  if ($manage_user) {
    user { $owner:
      ensure     => present,
      gid        => $group,
      home       => $homedir,
      managehome => $manage_home,
      system     => true,
      require    => Group[$group],
    }
  }
}
