
users { 'bootstrap': }

class { 'apt' : }

include apt::source

# Source network information from hiera
$net_config=hiera('network_config', {})

# Source host information from hiera
$host_information=hiera('host', {})

$dotfiles_information=hiera('dotfiles', {})

$dotfiles_repo_information=hiera('vcsrepo', {})

create_resources('network_config', $net_config)
create_resources('host', $host_information)
create_resources('vcsrepo', $dotfiles_repo_information)
create_resources('dotfiles', $dotfiles_information)
