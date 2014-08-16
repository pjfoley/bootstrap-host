class roles::puppetmaster {

  $my_ini_settings=hiera('ini_setting', {})
  create_resources('ini_setting', $my_ini_settings)

  include r10k
  include r10k::config
  include hiera

  Class['r10k::config'] ~> Class['hiera'] ~> Ini_setting['puppet_folder_environments'] ~> Exec['Download environments and hieradata']

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }

exec { 'Roles::Puppetmaster - Hosts file':
  command     => 'cat /etc/hosts',
  logoutput   => true,
}

exec { 'Roles::Puppetmaster - resolv.conf file':
  command     => 'cat /etc/hosts',
  logoutput   => true,
}

exec { 'Roles::Puppetmaster - Ping':
  command     => 'ping -c 5 dna.mgnt.local',
  logoutput   => true,
}

  # Use r10k to download environments and hieradata
  exec { 'Download environments and hieradata':
    command => 'r10k deploy environment -p -c /etc/r10k.yaml',
    notify  => Exec['Setup puppetmaster'],
  }

  # Need the second run due to etckeeper error during deb install
  exec { 'Setup puppetmaster':
    command     => 'puppet apply --config /etc/puppet/puppet.conf -e "hiera_include(\'classes\')"',
    refreshonly => true,
    logoutput   => true,
  }
}
