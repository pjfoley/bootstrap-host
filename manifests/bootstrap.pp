# Source user information through hiera
$ssh_users=hiera('ssh_users')
$ssh_root_keys =  $ssh_users['root']['ssh_keys']

# Source network information from hiera
$net_config=hiera('network_config')

# Source host information from hiera
$host_information=hiera('host', {})

# Add a place with the proper permissions for the SSH related configs
file { '/root/.ssh':
  ensure  => directory,
  owner   => root,
  group   => root,
  mode    => '0700',
}

# Add an authorized_keys file with proper permissions
file { '/root/.ssh/authorized_keys':
  ensure  => present,
  owner   => root,
  group   => root,
  mode    => '0600',
  require => File['/root/.ssh'],
}

Ssh_authorized_key {
  require => File['/root/.ssh/authorized_keys']
}

$ssh_key_defaults = {
  user  => root,
}

create_resources('ssh_authorized_key', $ssh_root_keys, $ssh_key_defaults)
create_resources('network_config', $net_config)
create_resources('host', $host_information)
