# bespin106_compute.pp

import 'bespin105_shared.pp'


node 'bespin106.east.isi.edu' {

  stage { 'first':
    before  => [ Stage['middle'], Stage['main'] ],
  }

  stage { 'middle':
    before  => Stage['main'],
    require => Stage['first'],
  }

  stage { 'last':
    require  => Stage['main'],
  }

  import 'defaults.pp'

  Exec {
    path => [
      '/usr/local/sbin',
      '/usr/sbin',
      '/sbin',
      '/bin',
      '/usr/local/bin',
      '/usr/bin'],

    logoutput => true,
  }

  notify { 'bespin106 compute node configuration':
    message => 'Running configuration of bespin106.east.isi.edu as OpenStack compute node.',
  }

  class { 'dodcs-selinux':
    stage          => middle,
    selinux_policy => 'permissive',
    require        => Class['dodcs-openstack-rpm'],
  }

  class { 'dodcs-prerequisites':
    stage          => first,
    package_ensure => present,
  }

  class { 'dodcs-repository':
    stage        => first,
    dodcs_image  => 'DODCS_folsom.iso',
    repo_release => 'folsom',
    require      => Class['dodcs-prerequisites'],
  }

  # The dodcs-openstack-rpm package must be run before openstack::contrller to get
  # DODCS-specific files installed. This package also brings in the OpenStack
  # packages.
  class {'dodcs-openstack-rpm':
    stage          => middle,
    package_ensure => present,
#    before         => [ Class['openstack::all'], Class['dodcs-selinux'] ],
    before         => [ Class['openstack::compute'], Class['dodcs-selinux'] ],
    require        => Class['dodcs-repository'],
  }

  class { 'openstack::compute':
    private_interface  => $private_interface,
#    internal_address   => $ipaddress_eth0,
    internal_address   => "10.0.5.6",
    libvirt_type       => 'kvm',
    fixed_range        => $fixed_range,
    network_manager    => 'nova.network.manager.FlatDHCPManager',
    multi_host         => false,
    sql_connection     => $sql_connection,
    rabbit_host        => $controller_node_internal,
    rabbit_password    => $rabbit_password,
    rabbit_user        => $rabbit_user,
    glance_api_servers => "${controller_node_internal}:9292",
    vncproxy_host      => $controller_node_public,
    vnc_enabled        => 'true',
    verbose            => $verbose,
#    manage_volumes     => true,
    manage_volumes     => false,
    nova_volume        => 'nova-volumes',
    network_config    => {
      flat_network_bridge => 'br100',
      force_dhcp_release => false,
      flat_injected => false,
      flat_interface => eth1,
      dhcpbridge  => '/usr/bin/nova-dhcpbridge',
      dhcpbridge_flagfile => '/etc/nova/nova.conf' },
    folsom_nova_conf   => {
      libvirt_inject_password   => true,
      allow_resize_to_same_host => true,
      buckets_path              => '/var/lib/nova/buckets',
      compute_driver            => 'gpu.GPULibvirtDriver',
      compute_scheduler_driver  => 'nova.scheduler.filter_scheduler.FilterScheduler',
      ec2_dmz_host              => '10.0.5.5',
      ec2_private_dns_show_ip   => true,
      fixed_ip_disassociate_timeout => '600',
      flat_network_dns          => '10.105.0.1',
      instance_name_template    => 'instance-%08x',
# For kvm
      instance_type_extra_specs => 'cpu_arch:x86_64',
# For lxc
#      instance_type_extra_specs => 'cpu_arch:x86_64, gpus:4, gpu_arch:fermi',
      instances_path            => '/var/lib/nova/instances',
      keystone_ec2_url          => "http://127.0.0.1:5000/v2.0/ec2tokens",
      libvirt_use_virtio_for_bridges => true,
      logging_context_format_string => '%(asctime)s %(levelname)s %(name)s [%(request_id)s %(user_name)s %(project_name)s] %(instance)s%(message)s',
      max_nbd_devices           => '16',
      multi_host                => false,
      my_ip                     => '10.106.0.1',
      network_size              => '65536',
      networks_path             => '/var/lib/nova/networks',
      osapi_compute_extension   => 'nova.api.openstack.compute.contrib.standard_extensions',
      periodic_interval         => '20',
# This is strange: used for cert keys path?
      pybasedir                 => '/var/lib/nova',
# Maybe it is this one...
      keys_path                 => '/var/lib/nova/keys',
      quota_cores               => '1024',
      quota_gigabytes           => '1000',
      quota_ram                 => '1024000',
      quota_volumes             => '100',
      rootwrap_config           => '/etc/nova/rootwrap.conf',
      send_arp_for_ha           => true,
      states_path               => '/var/lib/nova',
      vlan_interface            => eth1,
      volume_name_template      => 'volume-%s',
      use_cow_images            => false,
      xvpvncproxy_base_url      => 'http://10.105.0.1:6081/console' },
  }

  class { 'dodcs-postproc':
    stage   => last,
    require => Class['openstack::compute'],
  }

  # class { 'dodcs-postproc::dashboard':
  #   stage => last,
  # }

  # class { 'dodcs-postproc::nova-float':
  #   stage    => last,
  #   ip_range => "65.114.169.169/29",
  # }

}
