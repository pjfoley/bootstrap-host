
users { 'bootstrap': }

class { 'apt' : }

package { 'libpam-ssh-agent-sudo':
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
