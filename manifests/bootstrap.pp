
users { 'bootstrap': }

package { 'libpam-ssh-agent-auth':
  ensure  => installed,
  require => Apt::Source['ifoley.local'],
}

# Source network information from hiera
$net_config=hiera('network_config', {})
create_resources('network_config', $net_config)

Network_config['eth0'] ~> Exec['Bring eth0 link up if needed'] ~> Exec['Show addr'] ~> Exec['Show route']

Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ] }
exec { 'Bring eth0 link up if needed':
  command     => 'ifup eth0',
  #  command     => 'ip l s dev eth0 up',
  #  unless      => "ip a s dev eth0 | grep -q ',UP,'",
  logoutput   => true,
  refreshonly => true,
}

exec { 'Show addr':
  command     => 'ip addr show',
  logoutput   => true,
  refreshonly => true,
}

exec { 'Show route':
  command     => 'ip route show',
  logoutput   => true,
  refreshonly => true,
}

# Source host information from hiera
$host_information=hiera('host', {})
create_resources('host', $host_information)

$dotfiles_repo_information=hiera('vcsrepo', {})
create_resources('vcsrepo', $dotfiles_repo_information)

$dotfiles_information=hiera('dotfiles', {})
create_resources('dotfiles', $dotfiles_information)

$apt_repos=hiera('apt::sources', {})
create_resources('apt::source', $apt_repos)

file { '/etc/security/sudo_authorized_keys':
  ensure  => present,
  content => 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA1ZpF3Yh5jN5aqYh/xbM0q4Ea2RVzH2PnSYRNj/z16wT6pi/QzKgWRy4KeSbIy+LBdlP+jssSL7GorcvLIOtPisJR3qIuuq/x90Z0SXRB8obZWwVJF6AOclUaqcDMMhnCN3HkDUHtQMyp5hglgVtWoSC+29LL2knWuxgG/P2kBk4lWvAHJqkOTnqkfsrHrgHfW+txUGkFTOQZkzKeVb9Hi0Eny+IA1i41AWuGtC8z6AzLJRCz9Av0vJZly+fUZVHren1alZUp6Rqhr9moherLovY7rX1xFExXeFFW45pFl1TkJeEgvNF19zr41w+EgdXBo7Ojqhy1wBnHGVgBxlzNZQ== root-root@bootstrap',
  mode    => '0600',
  owner   => 'root',
  group   => 'root',
}

file { '/etc/pam.d/sudo':
  ensure  => present,
  content => "#%PAM-1.0\nauth sufficient pam_ssh_agent_auth.so file=/etc/security/sudo_authorized_keys\n@include common-auth\n@include common-account\n@include common-session-noninteractive",
  mode    => '0600',
  owner   => 'root',
  group   => 'root',
}

hiera_include('classes', '')
