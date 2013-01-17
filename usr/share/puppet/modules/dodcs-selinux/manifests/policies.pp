# policies.pp
#
# This class loads the selinux policy packages and adds DODCS OpenStack-
# specific policy.
#---------------------------------------------------------------------------- #

class dodcs-selinux::policies (
  $ensure            = 'latest',
  $dodcs_selinux_dir = '/usr/local/nova/SELINUX'
  ) {

  package { 'selinux-policy':
    ensure => $ensure,
  }

  package { 'selinux-policy-targeted':
    ensure => $ensure,
  }

  # The $dodcs_selinux_dir and this need to be better coordinated.
  file { '/usr/local/nova':
    ensure => directory,
    notify => File["$dodcs_selinux_dir"],
  }

  file { $dodcs_selinux_dir:
    ensure => directory,
    notify => Exec['dodcs-policies'],
  }

  exec { 'dodcs-policies':
    command     => "cp /usr/share/repo/DODCS/SELINUX/* ${dodcs_selinux_dir}",
    require     => File["${dodcs_selinux_dir}"],
    refreshonly => true,
    notify      => Exec['load-dodcs-policies'],
  }

  exec { 'load-dodcs-policies':
    command     => "semodule -i ${dodcs_selinux_dir}/hpcfolsom.pp",
    refreshonly => true,
    require     => Exec['dodcs-policies'],
  }

}
