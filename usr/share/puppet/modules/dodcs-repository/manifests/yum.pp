# Setup the yum repository for DODCS

class dodcs-repository::yum (
  $repo_filename,
  $repo_release  = 'folsom'
  ) {

  package { 'yum-plugin-priorities':
    ensure => present,
  }

  notify { 'yum-priorities-msg':
      message => 'yum-plugin-priorities present',
      require => Package['yum-plugin-priorities'],
    }

  case $operatingsystem {
    'CentOS': {
      # Assigns a lower priority to the RHEL ISO image.
      $iso_repo = "${repo_filename}.${repo_release}.CentOS"
      # Now put in a higher priority CentOS-Base repo.
      file { 'CentOS-Base.repo':
        ensure => present,
        path   => '/etc/yum.repos.d/CentOS-Base.repo',
        source => 'puppet:///modules/dodcs-repository/CentOS-Base.repo',
        require => File['/etc/yum.repos.d'],
      }
     }
     default: {
       # Makes RHEL ISO second only to the DODCS ISO image.
       $iso_repo = "${repo_filename}.${repo_release}"
     }
  }
       
  file { "${repo_filename}":
    ensure      => present,
    path        => "/etc/yum.repos.d/${repo_filename}",
    source      => "puppet:///modules/dodcs-repository/${iso_repo}",
    require     => [ Package['yum-plugin-priorities'], File['/etc/yum.repos.d'] ],
  }

  file { '/etc/yum.repos.d':
    ensure => directory,
  }
}
  
