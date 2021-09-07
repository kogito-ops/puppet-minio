# @summary
#   Manages a Minio client (mc) installation various Linux/BSD operating systems.
#
# @example
#   class { 'minio::client::install':
#       package_ensure         => 'present',
#       base_url               => 'https://dl.minio.io/client/mc/release',
#       version                => 'RELEASE.2021-07-27T06-46-19Z',
#       checksum               => '0df81285771e12e16a0c4c2f5e0ebc700e66abb8179013cc740d48b0abad49be',
#       checksum_type          => 'sha256',
#       installation_directory => '/usr/local/bin',
#       binary_name            => 'minio-client'
#   }
#
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
class minio::client::install(
  Enum['present', 'absent'] $package_ensure             = $minio::client::package_ensure,
  Stdlib::HTTPUrl $base_url                             = $minio::client::base_url,
  String $version                                       = $minio::client::version,
  String $checksum                                      = $minio::client::checksum,
  String $checksum_type                                 = $minio::client::checksum_type,
  Stdlib::Absolutepath $installation_directory          = $minio::client::installation_directory,
  String $binary_name                                   = $minio::client::binary_name,
) {
  $kernel_down = downcase($::kernel)

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

  $source_url = "${base_url}/${kernel_down}-${arch}/archive/mc.${version}"
  $target = "${installation_directory}/${binary_name}"
  $link_ensure = $package_ensure ? {
    'present' => 'link',
    'absent' => 'absent'
  }

  archive::download { $target:
    ensure        => $package_ensure,
    checksum      => true,
    digest_string => $checksum,
    digest_type   => $checksum_type,
    url           => $source_url,
  }
  -> file { $target:
    ensure => $package_ensure,
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  -> file { '/root/.minioclient':
    ensure => $link_ensure,
    target => $target,
  }
}
