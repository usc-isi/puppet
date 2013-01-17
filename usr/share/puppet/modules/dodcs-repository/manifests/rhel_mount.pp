# 
# Class checks the current ISO image for the DODCS RPMs and updates.
#
class dodcs-repository::rhel_mount (
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
