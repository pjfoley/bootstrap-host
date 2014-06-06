
users { 'bootstrap': }

class { 'apt' : }

package { 'libpam-ssh-agent-auth':
  ensure  => installed,
  require => Apt::Source['ifoley.local'],
}

include sudo
include sudo::configs

# Source network information from hiera
$net_config=hiera('network_config', {})
create_resources('network_config', $net_config)


# Source host information from hiera
$host_information=hiera('host', {})
create_resources('host', $host_information)

$dotfiles_repo_information=hiera('vcsrepo', {})
create_resources('vcsrepo', $dotfiles_repo_information)

$dotfiles_information=hiera('dotfiles', {})
create_resources('dotfiles', $dotfiles_information)

#$pam_services_defaults = {
#  require => Package['libpam-ssh-agent-sudo'],
#}

#$pam_services=hiera('pam::services', {})
#create_resources('pam::service', $pam_services, $pam_services_defaults)

$apt_repos=hiera('apt::sources', {})
create_resources('apt::source', $apt_repos)

notify { 'Ensuring sudo authorized key file' : }
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

notify { "What is my role ${machine_role}" : }
hiera_include('classes')
