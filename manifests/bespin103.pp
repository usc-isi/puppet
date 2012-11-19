# bespin103.pp
# Setup bespin103 as an automated testing host for lxc VMs.

node 'bespin103.east.isi.edu' {

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

  notify { 'bespin103 configuration':
    message => 'Running configuration of bespin103.east.isi.edu',
  }

  class { 'dodcs-selinux':
    stage          => first,
    selinux_policy => 'permissive',
  }

  class { 'dodcs-prerequisites':
    stage          => first,
    package_ensure => present,
  }

  class { 'dodcs-repository':
    stage        => first,
    dodcs_image  => 'DODCS_folsom.iso',
    repo_release => 'folsom',
    require      => Class['dodcs-selinux','dodcs-prerequisites'],
#    before       => Class['dodcs-openstack-rpm'],
  }

  class {'dodcs-openstack-rpm':
    stage          => middle,
    package_ensure => present,
    before         => Class['openstack::all'],
    require        => Class['dodcs-repository'],
  }

  class { 'mysql::python':  }

  class { 'mysql::ruby':
    package_name => 'ruby-mysql',
  }

# This uses Puppet Labs's OpenStack modules (maybe only for 2.7.x)
  class { 'openstack::all':
    stage                 => main,
    public_address        => '65.123.202.103',
    public_interface      => eth0,
    private_interface     => eth1,
#  where to put? flat_interface = eth1
    network_config        => { flat_network_bridge => 'br100',
                               force_dhcp_release => false,
                               flat_injected => false,
                               flat_interface => eth1,
                               dhcpbridge  => '/usr/bin/nova-dhcpbridge',
                               dhcpbridge_flagfile => '/etc/nova/nova.conf' },
    fixed_range           => '10.67.0.0/24',
    mysql_root_password   => 'd0dcSdba',
    rabbit_host           => '10.67.0.1',
    rabbit_password       => 'd0dcSdba',
    admin_email           => 'cward@isi.edu',
    admin_password        => 'secrete',
    keystone_db_password  => 'keystone_dba',
    keystone_admin_token  => '999888777666',
    nova_db_password      => 'nova_dba',
    nova_user             => 'admin',
    nova_user_password    => 'secrete',
    nova_tenant           => 'admin',
    glance_db_password    => 'glance_dba',
    glance_user           => 'admin',
    glance_user_password  => 'secrete',
    glance_tenant         => 'admin',
    purge_nova_config     => false,
    libvirt_type          => 'lxc',
    nova_volume           => 'nova-volumes',
    iscsi_ip_address      => '10.67.0.1',
    verbose               => true,
    package_ensure        => 'present',
    folsom_nova_conf      => {
      allow_resize_to_same_host => true,
      buckets_path              => '/var/lib/nova/buckets',
      compute_driver            => 'gpu.GPULibvirtDriver',
      compute_scheduler_driver  => 'nova.scheduler.filter_scheduler.FilterScheduler',
      ec2_dmz_host              => '65.123.202.103',
      ec2_private_dns_show_ip   => true,
      fixed_ip_disassociate_timeout => '600',
      flat_network_dns          => '10.67.0.1',
      instance_name_template    => 'instance-%08x',
      instance_type_extra_specs => 'cpu_arch:x86_64, gpus:4, gpu_arch:fermi',
      instances_path            => '/var/lib/nova/instances',
      keystone_ec2_url          => "http://127.0.0.1:5000/v2.0/ec2tokens",
      libvirt_use_virtio_for_bridges => true,
      logging_context_format_string => '%(asctime)s %(levelname)s %(name)s [%(request_id)s %(user_name)s %(project_name)s] %(instance)s%(message)s',
      max_nbd_devices           => '16',
      multi_host                => false,
      my_ip                     => '10.67.0.1',
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
      xvpvncproxy_base_url      => 'http://10.67.0.1:6081/console' },
    require               => Package['dodcs-openstack'],
  }

  class { 'dodcs-postproc':
    stage   => last,
    require => Class['openstack::all'],
  }

  # This is supposed to tell Puppet how to sequence these classes and packages.
  # They should go left-to-right: Do['this'] -> (before) Do['that']
#  Class['dodcs-selinux'] -> Class['dodcs-prerequisites'] ->  Class['dodcs-repository'] ->  Package['dodcs-openstack'] -> Class['mysql::python'] -> Class['mysql::ruby'] -> Class['openstack::all'] -> Class['dodcs-postproc']

}
