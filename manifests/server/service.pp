# @summary
#   Manages services for the `::minio::server` class.
#
# @example
#   class { 'minio::server::service':
#       manage_service          => true,
#       service_provider        => 'systemd',
#       service_ensure          => 'running',
#   }
#
# @param [Boolean] manage_service
#   Should we manage a server service definition for Minio?
# @param [Stdlib::Ensure::Service] service_ensure
#   Defines the state of the minio server service.
# @param [String] service_provider
#   Which service provider do we use?
#
# @author Daniel S. Reichenbach <daniel@kogitoapp.com>
# @author Evgeny Soynov <esoynov@kogito.network>
#
# Copyright
# ---------
#
# Copyright 2017-2021 Daniel S. Reichenbach <https://kogitoapp.com>
#
class minio::server::service (
  Boolean                 $manage_service   = $minio::server::manage_service,
  Stdlib::Ensure::Service $service_ensure   = $minio::server::service_ensure,
  String                  $service_provider = $minio::server::service_provider,
  ) {

  if ($manage_service) {
    service { 'minio':
      ensure     => $service_ensure,
      enable     => true,
      hasstatus  => false,
      hasrestart => false,
      provider   => $service_provider,
    }
  }
}
