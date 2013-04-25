# == Class: isi::dodcs::selinux::config
#
# Configure SELinux to work with DODCS OpenStack Folsom.
# ------------------------------------------------------------------- #
# SELinux policy options are:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
# ------------------------------------------------------------------- #
# TODO: Does this conver enough? Should an OS module be tried?
# ------------------------------------------------------------------- #
#
# === Parameters
#
# [selinux_policy] SELinux policy option. See above for allowable options. Required.
#
# === Examples
#
# class { 'isi::dodcs::selinux::config': {
#   selinux_policy => 'permissive',
# }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::dodcs::selinux::config (
      $selinux_policy
  ) {


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
    source  => "puppet:///modules/isi/dodcs/selinux/config.selinux.${selinux_policy}",
    require => File['/etc/selinux'],
  }

  class {'isi::dodcs::selinux::policies':
    ensure            => 'latest',
    dodcs_selinux_dir => '/usr/local/nova/SELINUX',
  }

  exec { "change-selinux-status-to-${selinux_policy}":
    command => "echo ${sestatus} > /selinux/enforce",
    unless  => "grep -q '${sestatus}' /selinux/enforce",
  }

}
