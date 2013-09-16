class git ($name = 'Dimitar Dimitrov', $email = 'mitkofr@yahoo.fr') {

  package { 'dev-vcs/git':
    ensure => latest,
  }

  exec { 'git-config':
    command     => ["git config --global user.name $name",
                    "git config --global user.email $email",
                    'git config --global color.ui true'],
    refreshonly => true,
  }

  Package['dev-vcs/git'] ~> Exec['git-config']
}
