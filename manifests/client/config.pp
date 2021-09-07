# @summary
#   Manages a Minio client (mc) configuration various Linux/BSD operating systems.
#
# @example
#   class { 'minio::client::config':
#       aliases                 => {
#         'default' => {
#           'ensure'              => 'present',
#           'endpoint'            => 'http://localhost:9000',
#           'access_key'          => 'admin',
#           'secret_key'          => Sensitive('password'), # can also be a string
#           'api_signature'       => 'S3v4', # optional
#           'path_lookup_support' =>'on',    # optional
#         }
#       },
#       purge_unmanaged_aliases => true
#   }
#
# @param [Hash] aliases
#   List of aliases to add to the minio client configuration. For parameter description see `minio_client_alias`.
# @param [Boolean] purge_unmanaged_aliases
#   Decides if puppet should purge unmanaged minio client aliases
#
# @author Daniel S. Reichenbach <daniel@kogitoapp.com>
# @author Evgeny Soynov <esoynov@kogito.network>
#
class minio::client::config(
  Hash $aliases                                         = $minio::client::aliases,
  Boolean $purge_unmanaged_aliases                      = $minio::client::purge_unmanaged_aliases,
) {
  if ($purge_unmanaged_aliases) {
    resources {'minio_client_alias':
      purge => true,
    }
  }

  $aliases.each | $alias, $alias_values | {
    minio_client_alias {$alias:
      * => $alias_values,
    }
  }
}
