# Class: nova::volume::iscsi
#
# iscsi is the default volume driver for OpenStack. 
#
# [*Parameters*]
#
# [volume_group] Name of the volume group to use.
#  Optional. Defaults to 'nova-volumes' - the OpenStack default.
#
# [iscsi_helper] Name of the iscsi helper to use.
#  Optional. Defaults to 'tgtadm' - the OpenStack default. 
#
# [iscsi_ip_address] IP address on the nova-volume server where
#   compute nodes will connect to for volumes.
#   Optional. Defaults to undef. OpenStack defaults to server IP.
#
# This class assumes that you have already configured your 
# volume group - either by another module or during the server
# provisioning
#
class nova::volume::iscsi (
  $volume_group     = 'nova-volumes',
  $iscsi_helper     = 'tgtadm',
  $iscsi_ip_address = undef
) {

  include 'nova::params'
  
  nova_config { 'volume_group': value => $volume_group }

  if $iscsi_ip_address {
    nova_config { 'iscsi_ip_address': value => $iscsi_ip_address }
  }

  case $iscsi_helper {
    'tgtadm': {
      package { 'tgt':
        name   => $::nova::params::tgt_package_name,
        ensure => present,
      }
      service { 'tgtd':
        name     => $::nova::params::tgt_service_name,
        provider => $::nova::params::special_service_provider,
        ensure   => running,
        enable   => true,
        require  => [Nova::Generic_service['volume'], Package['tgt']],
      }
      ## DODCS
      # Quick hack to get needed include line into this file.
      file { 'targets.conf':
        ensure      => present,
        path        => "/etc/tgt/targets.conf",
        source      => "puppet:///modules/nova/targets.conf.dodcs",
        owner       => 'root',
        group       => 'root',
        mode        => '0600',
        require     => Package['tgt'],
        notify      => Service['tgtd'],
      }

      # This is the default, but might as well be verbose
      nova_config { 'iscsi_helper': value => 'tgtadm' }
    }

    default: {
        fail("Unsupported iscsi helper: ${iscsi_helper}. The supported iscsi helper is tgtadm.")
    }
  }
}
