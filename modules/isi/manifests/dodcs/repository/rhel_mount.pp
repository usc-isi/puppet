#  [== TODO: Needs to be rewritten to use mount resource. ==]
# == Class: isi::dodcs::repository::rhel_mount
#
# Class checks the current ISO image for the Red Hat Enterprise Linux RPMs and updates if the
# Puppet master has a new copy of the file. Should be staged before the
# isi::dodcs::openstack class.
#
# Expected use of this class is through the isi::dodcs::respository::shared-iso
# class. It should not be used directly.
#
# NB: This class was used for the Folsom release of DODCS OpenStack. It might
# not be suitable for later releases.
#
# === Parameters
#
# [rhel_image] Name of ISO image file to mount. Required.
# [rhel_mount] Path to mount point for ISO image. Required.
#
# === Examples
#
#  class { 'isi::dodcs::repository::rhel_mount':
#    rhel_image => '/usr/share/iso/RHEL.iso',
#    rhel_mount => '/usr/share/repo/RHEL',
#  }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::dodcs::repository::rhel_mount (
  $rhel_image,
  $rhel_mount
  ) {

  # Getting the ISO image for mounting an use by YUM
  file { $rhel_image:
    path   => "/usr/share/iso/${rhel_image}",
    ensure => present,
    source => "puppet:///iso_files/${rhel_image}",
    checksum => md5,
    require => [ File['/usr/share/iso'], File['/usr/share/repo'], File["$rhel_mount"] ],
    notify => Exec['rhel_image_umount'],
  }

  file { $rhel_mount:
    ensure => directory,
  }
  
  exec { 'rhel_image_umount':
    command     => "umount ${rhel_mount}",
    before      => Exec['rhel_image_mount'],
    subscribe   => File["${rhel_image}"],
    notify      => Exec['rhel_image_mount'],
    onlyif      => "grep $rhel_mount /proc/mounts",
    refreshonly => true,
  }
  # Need to figure out how to tie this to a change in $rhel_image
  # -> The "refreshonly," "notify," and "checksum" attributes seem the way.
  exec { 'rhel_image_mount':
    command     => "mount -o loop /usr/share/iso/${rhel_image} ${rhel_mount}",
    subscribe   => [ Exec['rhel_image_umount'], File["${rhel_image}"] ],
    refreshonly => true,
    unless      => "grep $rhel_mount /proc/mounts",  }

}
