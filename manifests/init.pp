# minio
#
# Main class, includes all other classes.
#
# @summary Manage Minio to run self-hosted S3 storage
#
# @example
#   include minio
class minio {
  contain ::minio::user
  contain ::minio::install
  contain ::minio::config
  contain ::minio::service

  Class['::minio::user']
  -> Class['::minio::install']
  -> Class['::minio::config']
  ~> Class['::minio::service']
}
