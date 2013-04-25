#  [== TODO: Needs to be rewritten to use mount resource. ==]
# 
# Class checks the current ISO image for the DODCS RPMs and updates.
#
class dodcs-repository::dodcs_mount (
  $dodcs_image,
  $dodcs_mount
  ) {

    # Getting the ISO image for mounting an use by YUM
  file { $dodcs_image:
    path        => "/usr/share/iso/${dodcs_image}",
    ensure      => present,
    source      => "puppet:///iso_files/${dodcs_image}",
    checksum    => md5,
    require     => [ File['/usr/share/iso'], File['/usr/share/repo'], File["$dodcs_mount"] ],
    notify      => Exec['dodcs_image_umount'],
  }

  file { $dodcs_mount:
    ensure => directory,
  }

  exec { 'dodcs_image_umount':
    command     => "umount ${dodcs_mount}",
    subscribe   => File["${dodcs_image}"],
    refreshonly => true,
    notify      => Exec['dodcs_image_mount'],
    onlyif      => "grep $dodcs_mount /proc/mounts",
  }

  # Need to figure out how to tie this to a change in $dodcs_image
  # -> The "refreshonly," "notify," and "checksum" attributes seem the way.
  exec { 'dodcs_image_mount':
    command     => "mount -o loop /usr/share/iso/${dodcs_image} ${dodcs_mount}",
    subscribe   => [ Exec['dodcs_image_umount'], File["${dodcs_image}"] ],
    refreshonly => true,
    unless      => "grep $dodcs_mount /proc/mounts",
    notify      => Exec["yum_refresh"],
  }

  exec { 'yum_refresh':
    command   => 'yum clean all',
    subscribe => Exec['dodcs_image_mount'],
  }

}
