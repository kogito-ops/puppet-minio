# @summary Manages a Minio client (mc) installation on various Linux/BSD operating systems.
#
#
# @example
#   class { 'minio::client':
#       manage_client_installation => true,
#       package_ensure             => 'present',
#       base_url                   => 'https://dl.minio.io/client/mc/release',
#       version                    => 'RELEASE.2021-07-27T06-46-19Z',
#       checksum                   => '0df81285771e12e16a0c4c2f5e0ebc700e66abb8179013cc740d48b0abad49be',
#       checksum_type              => 'sha256',
#       installation_directory     => '/opt/minioclient',
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
) {
  if ($manage_client_installation) {
    file { $installation_directory:
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      recurse => true,
    }

    $kernel_down=downcase($::kernel)

    case $::architecture {
      /(x86_64)/: {
        $arch = 'amd64'
      }
      /(x86)/: {
        fail('Minio client does not support x86 architecture')
      }
      default: {
        $arch = $::architecture
      }
    }

    $source_url="${base_url}/${kernel_down}-${arch}/archive/mc.${version}"

    archive::download { "${installation_directory}/mc":
      ensure        => $package_ensure,
      checksum      => true,
      digest_string => $checksum,
      digest_type   => $checksum_type,
      url           => $source_url,
    }
    -> file {"${installation_directory}/mc":
      ensure => $package_ensure,
      mode   => '0755',
      owner  => 'root',
      group  => 'root',
    }
  }
}
