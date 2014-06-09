class roles::puppetmaster {

  $my_ini_settings=hiera('ini_setting', {})
  create_resources('ini_setting', $my_ini_settings)

  # Use r10k to download environments and hieradata
  exec { 'Download environments and hieradata':
    command     => 'r10k deploy environment -p',
    subscribe   => Class ['r10k::config'],
    refreshonly => true,
  } ->
  # Need the second run due to etckeeper error during deb install
  exec { 'Setup puppetmaster':
    command     => '/usr/bin/puppet -e "include profiles::puppetmaster"',
    refreshonly => true,
    reture      => Exec['Disable etckeeper'],
    notify      => Exec['Enable etckeeper'],
  }

  exec { 'Disable etckeeper':
    command     => '/bin/mv /etc/apt/apt.conf.d/05etckeeper /root/tmp',
    onlyif      => '/usr/bin/test -e /etc/apt/apt.conf.d/05etckeeper',
    refreshonly => true,
  }

  exec { 'Enable etckeeper':
    command     => '/bin/mv /root/tmp /etc/apt/apt.conf.d/05etckeeper',
    onlyif      => '/usr/bin/test -e /root/tmp/05etckeeper',
    refreshonly => true,
  }
}
