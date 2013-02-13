# dodcs-selinux
#
# Configure SELinux to work with DODCS OpenStack.
# ------------------------------------------------------------------- #
# SELinux policy options are:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
# ------------------------------------------------------------------- #
# TODO: Does this conver enough? Should an OS module be tried?
# ------------------------------------------------------------------- #

class dodcs-selinux (
      $selinux_policy = 'permissive'
  ) {

  # #+
  # # This will disable SELinux in current session.
  # #-
  # file { 'selinux':
  #   ensure  => present,
  #   path    => '/selinux/enforce',
  #   content => "0",
  #   owner   => 'root',
  # }

  case $selinux_policy {
    permissive,disabled: {
      $sestatus = '0'
    }
    enforcing: {
      $sestatus = '1'
    }
    default : {
      fail('You must specify a selinux policy (enforced, permissive, or disabled) for selinux operations')
    }
  }

  file { '/etc/selinux':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/etc/selinux/config':
    ensure  => present,
    path    => '/etc/selinux/config',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/dodcs-selinux/config.selinux.${selinux_policy}",
    require => File['/etc/selinux'],
  }

  class {'dodcs-selinux::policies':
    ensure            => 'latest',
    dodcs_selinux_dir => '/usr/local/nova/SELINUX',
  }

  exec { "change-selinux-status-to-${selinux_policy}":
    command => "echo ${sestatus} > /selinux/enforce",
    unless  => "grep -q '${sestatus}' /selinux/enforce",
  }

}
