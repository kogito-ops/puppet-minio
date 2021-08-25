# @summary
#   Manages user for the minio server installations.
#
# @example
#   class {'minio::server::user':
#         manage_user  => true,
#         manage_group => true,
#         manage_home  => true,
#         owner        => 'minio',
#         group        => 'minio',
#         home         => '/home/minio'
#   }
#
# @param [Boolean] manage_user
#   Should we manage provisioning the user?
# @param [Boolean] manage_group
#   Should we manage provisioning the group?
# @param [Boolean] manage_home
#   Should we manage provisioning the home directory?
# @param [String] owner
#   The user owning minio and its' files.
# @param [String] group
#   The group owning minio and its' files.
# @param [Optional[Stdlib::Absolutepath]] home
#   Qualified path to the users' home directory.
#
# @author Daniel S. Reichenbach <daniel@kogitoapp.com>
# @author Evgeny Soynov <esoynov@kogito.network>
#
# Copyright
# ---------
#
# Copyright 2017-2021 Daniel S. Reichenbach <https://kogitoapp.com>
#
class minio::server::user (
  Boolean                                 $manage_user                 = $minio::server::manage_user,
  Boolean                                 $manage_group                = $minio::server::manage_group,
  Boolean                                 $manage_home                 = $minio::server::manage_home,
  String                                  $owner                       = $minio::server::owner,
  String                                  $group                       = $minio::server::group,
  Optional[Stdlib::Absolutepath]          $home                        = $minio::server::home,
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
