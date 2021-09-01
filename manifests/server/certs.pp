# @summary
#   Manages minio certificate deployment.
#
# @example
#   class {'minio::server::certs':
#     cert_ensure                => 'present',
#     owner                      => 'minio',
#     group                      => 'minio',
#     cert_directory             => '/etc/minio/certs',
#     default_cert_configuration => {
#       'source_path'      => 'puppet:///modules/minio/examples',
#       'source_cert_name' => 'localhost',
#       'source_key_name'  => 'localhost',
#     },
#
#     additional_certs           => {
#       'example' => {
#         'source_path'      => 'puppet:///modules/minio/examples',
#         'source_cert_name' => 'example.test',
#         'source_key_name'  => 'example.test',
#       }
#     }
#   }
#
# @param [Enum['present', 'absent']] cert_ensure
#   Decides if minio certificates binary will be installed.
# @param [String] owner
#   The user owning minio cerfificates.
# @param [String] group
#   The group owning minio certificates.
# @param [Stdlib::Absolutepath] cert_directory
#   Directory where minio will keep all cerfiticates.
# @param [Optional[Hash]] default_cert_configuration
#   Hash with the configuration for the default certificate. See `certs::site`
#   of the `broadinstitute/certs` module for parameter descriptions.
# @param [Optional[Hash]] additional_certs
#   Hash of the additional certificates to deploy. The key is a directory name, value is
#   a hash of certificate configuration. See `certs::site` of the `broadinstitute/certs`
#   module for parameter descriptions. **Important**: if you use additional certificates,
#   their corresponding SAN names should be filled for SNI to work.
#
class minio::server::certs(
  Enum['present', 'absent'] $cert_ensure = $minio::server::cert_ensure,
  String $owner = $minio::server::owner,
  String $group = $minio::server::group,
  Stdlib::Absolutepath $cert_directory = $minio::server::cert_directory,
  Optional[Hash] $default_cert_configuration = $minio::server::default_cert_configuration,
  Optional[Hash] $additional_certs = $minio::server::additional_certs,
) {
  $link_ensure = $cert_ensure ? {
    'present' => 'link',
    default   => 'absent',
  }

  if (!empty($default_cert_configuration)) {
    certs::site { 'default':
      ensure    => $cert_ensure,
      cert_path => $cert_directory,
      key_path  => $cert_directory,
      owner     => $owner,
      group     => $group,
      *         => $default_cert_configuration,
    }

    -> file {"${cert_directory}/private.key":
      ensure => $link_ensure,
      target => "${cert_directory}/default.key",
      mode   => '0600',
      owner  => $owner,
      group  => $group,
    }

    -> file {"${cert_directory}/public.crt":
      ensure => $link_ensure,
      target => "${cert_directory}/default.pem",
      mode   => '0600',
      owner  => $owner,
      group  => $group,
    }
  }

  $additional_certs.each | $name, $cert_values | {
    certs::site {$name:
      ensure    => $cert_ensure,
      cert_path => "${cert_directory}/${name}",
      key_path  => "${cert_directory}/${name}",
      owner     => $owner,
      group     => $group,
      *         => $cert_values,
    }
    -> file {"${cert_directory}/${name}/private.key":
      ensure => $link_ensure,
      target => "${cert_directory}/${name}/${name}.key",
      mode   => '0600',
      owner  => $owner,
      group  => $group,
    }
    -> file {"${cert_directory}/${name}/public.crt":
      ensure => $link_ensure,
      target => "${cert_directory}/${name}/${name}.pem",
      mode   => '0600',
      owner  => $owner,
      group  => $group,
    }
  }
}
