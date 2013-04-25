# == Class: isi::dodcs::repository::rhel_mount
#
# Setup YUM repository for DODCS OpenStack
# Should be staged before the isi::dodcs::openstack class.
#
# NB: This class was used for the Folsom release of DODCS OpenStack. It might
# not be suitable for later releases.
#
# === Parameters
#
# [repo_filename] Name of repository for yum use. Optional. Default iso.repo.
# [repo_release] Version of release for DODCS Openstack. Optional. Default folsom.
# [dodcs_image] Name of ISO image file to mount. Optional. Default DODCS_folsom.iso.
# [dodcs_mount] Path to mount point for ISO image. Optional. Default /usr/share/repo/DODCS.
# [rhel_image] Name of ISO image file to mount. Optional. Default RHEL.iso.
# [rhel_mount] Path to mount point for ISO image. Optional. Default /usr/share/repo/RHEL.
#
# === Examples
#
#  class { 'isi::dodcs::repository::shared-iso':
#    stage         => first,
#    repo_filename => 'iso.repo',
#    dodcs_image   => 'DODCS_folsom.iso',
#    dodcs_mount   => '/usr/share/repo/DODCS',
#    rhel_mount    => '/usr/share/repo/RHEL',
#    rhel_image    => 'RHEL.iso',
#    repo_release  =>'folsom',
#  }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
#
class isi::dodcs::repository::shared-iso (
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

  class { 'isi::dodcs::repository::yum':
    repo_filename => $repo_filename,
    repo_release  => $repo_release,
  }

  class  { 'isi::dodcs::repository::dodcs_mount':
    dodcs_image => $dodcs_image,
    dodcs_mount => $dodcs_mount,
  }

  class { 'isi::dodcs::repository::rhel_mount':
    rhel_image => $rhel_image,
    rhel_mount => $rhel_mount,
  }

  # Help Puppet agent with order of applying resources.
  File['/usr/share/iso'] -> File['/usr/share/repo'] -> Class['isi::dodcs::repository::yum'] -> Class['isi::dodcs::repository::dodcs_mount'] -> Class['isi::dodcs::repository::rhel_mount']
}
