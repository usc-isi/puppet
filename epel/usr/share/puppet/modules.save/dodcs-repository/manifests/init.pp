# Setup YUM repository for DODCS OpenStack
#
# This revision will only work for yum systems.
#
class dodcs-repository (
  $repo_filename = 'iso.repo',
  $dodcs_image   = 'DODCS_folsom.iso',
  $dodcs_mount   = '/usr/share/repo/DODCS',
  $rhel_mount    = '/usr/share/repo/RHEL',
  $rhel_image    = 'RHEL.iso',
  $repo_release  = 'folsom'
  ) {

  file { '/usr/share/iso':
    ensure => directory,
  }

  file { '/usr/share/repo':
    ensure => directory,
  }

  class { 'dodcs-repository::yum':
    repo_filename => $repo_filename,
    repo_release  => $repo_release,
  }

  class  { 'dodcs-repository::dodcs_mount':
    dodcs_image => $dodcs_image,
    dodcs_mount => $dodcs_mount,
  }

  class { 'dodcs-repository::rhel_mount':
    rhel_image => $rhel_image,
    rhel_mount => $rhel_mount,
  }

  # Help Puppet agent with order of applying resources.
  File['/usr/share/iso'] -> File['/usr/share/repo'] -> Class['dodcs-repository::yum'] -> Class['dodcs-repository::dodcs_mount'] -> Class['dodcs-repository::rhel_mount']
}
