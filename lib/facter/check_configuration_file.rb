require 'facter'

Facter.add(:check_configuration_file) do
  setcode do
    File.exist? '/etc/minio/config.json'
  end
end
