# DODCS post processing

class dodcs-postproc {
  
  file { 'iptables-setup':
    path   => '/etc/dodcs/iptables-setup.sh',
    ensure => present,
    mode   => '0700',
    owner  => 'root',
    group  => 'root',
    content => template('dodcs-postproc/iptables-setup.sh.erb'),
    require => File['/etc/dodcs'],
  }

  file {'/etc/dodcs':
    ensure => directory,
  }

  exec {'iptables-setup':
    command => '/etc/dodcs/iptables-setup.sh',
    refreshonly => true,
    subscribe => File['iptables-setup'],
  }
}
