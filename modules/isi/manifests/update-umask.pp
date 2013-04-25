# Script to post-process some of the service scripts to modify the umask
# for the running process.  Without the update, file permissions can prevent
# OpenStack processes from running correctly.

class isi::update-umask (
  $dirpath = '/root/umask-update',
  $cmdexe  = 'update-umask.sh'
  ) {

  
  notify { "Preparing to run ${dirpath}/${cmdexe}": }

  file { "$dirpath":
    ensure => directory,
  }

  file {'update-umask':
    ensure => file,
    path => "${dirpath}/${cmdexe}",
    source => "puppet:///isi/${cmdexe}",
    mode => 0755,
    require => File["$dirpath"],
  }

  # After creating file, execute it. It should detect files it has
  # already updated.
  exec {'run-update-umask':
    command => "${dirpath}/${cmdexe}",
    require => File['update-umask'],
  }
}
