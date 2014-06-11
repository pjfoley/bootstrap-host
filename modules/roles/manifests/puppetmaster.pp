class roles::puppetmaster {

  $my_ini_settings=hiera('ini_setting', {})
  create_resources('ini_setting', $my_ini_settings)

  Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

  # Use r10k to download environments and hieradata
  exec { 'Download environments and hieradata':
    command => 'r10k deploy environment -p',
    notfiy  => Exec['Setup puppetmaster'],
  } ->
  exec { 'Disable etckeeper':
    command     => 'mv /etc/apt/apt.conf.d/05etckeeper /root/tmp',
    onlyif      => 'test -e /etc/apt/apt.conf.d/05etckeeper',
  }

  # Need the second run due to etckeeper error during deb install
  exec { 'Setup puppetmaster':
    command     => 'puppet -e "include profiles::puppetmaster"',
    refreshonly => true,
    notify      => Exec['Enable etckeeper'],
  }

  exec { 'Enable etckeeper':
    command     => 'mv /root/tmp /etc/apt/apt.conf.d/05etckeeper',
    onlyif      => 'test -e /root/tmp/05etckeeper',
    refreshonly => true,
  }
}
