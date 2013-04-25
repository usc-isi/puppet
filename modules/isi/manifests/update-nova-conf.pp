# Run a script that removes some nova-network settings from nova.conf.

class isi::update-nova-conf (
  $dirpath = '/root/nova-conf-update',
  $cmdexe  = 'update-nova-conf.sh'
  ) {


  notify { "Preparing to run ${dirpath}/${cmdexe}": }
  
  file { "$dirpath":
    ensure => directory,
  }

  file {'update-nova-conf':
    ensure => file,
    path => "${dirpath}/${cmdexe}",
    source => "puppet:///isi/${cmdexe}",
    mode => 0755,
    require => File["$dirpath"],
  }

  # After creating file, execute it. It should detect files it has
  # already updated.
  exec {'run-update-nova-conf':
    command => "${dirpath}/${cmdexe}",
    require => File['update-nova-conf'],
  }
}
