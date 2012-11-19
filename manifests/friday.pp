# friday.pp
# Setup bespin250 as an automated testing host for kvm VMs.

node 'friday.east.isi.edu' {

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
    path => [ '/bin',
              '/usr/bin',
              '/usr/local/bin',
              '/usr/local/sbin',
              '/usr/sbin',
              '/sbin' ],

    logoutput => true,
  }

  notify { 'friday configuration':
    message => 'Running configuration of friday.east.isi.edu',
  }


  class { 'dodcs-selinux':
    stage          => first,
    selinux_policy => 'disabled',
  }

  # move into dodcs-selinux class
  # class {'dodcs-selinux-policy':
  #   stage  => first,
  #   ensure => 'latest',
  # }

  class { 'dodcs-prerequisites':
    stage          => first,
    package_ensure => present,
  }


  class { 'dodcs-repository':
    stage        => first,
    dodcs_image  => 'DODCS_folsom.iso',
    repo_release => 'folsom',
    require      => Class['dodcs-selinux','dodcs-prerequisites'],
    notify       => Class['dodcs-openstack-rpm'],
  }

  class {'dodcs-openstack-rpm':
    stage          => middle,
    package_ensure => present,
    before         => Class['openstack::all'],
    require        => Class['dodcs-repository'],
    notify         => Class['openstack::all'],
  }

# This uses Puppet Labs's OpenStack modules. Requires function 'create_resources'
# if using with Puppet 2.6.x; default part of 2.7.x and later.
  class { 'openstack::all':
    stage                 => main,
    public_address        => '65.114.169.144',
    public_interface      => eth0,
    private_interface     => eth0,
    network_config        => { flat_network_bridge => 'br100',
                               force_dhcp_release => false,
                               flat_injected => false,
                               flat_interface => eth0,
                               dhcpbridge  => '/usr/bin/nova-dhcpbridge',
                               dhcpbridge_flagfile => '/etc/nova/nova.conf' },
    fixed_range           => '10.77.0.0/24',
    mysql_root_password   => 'd0dcSdba',
    rabbit_host           => '10.77.0.1',
    rabbit_password       => 'd0dcSdba',
    admin_email           => 'cward@isi.edu',
    admin_password        => 'dodcsecret',
    keystone_db_password  => 'keystone_dba',
    keystone_admin_token  => '999888777666',
    nova_db_password      => 'nova_dba',
    nova_user_password    => 'nova_user',
    glance_db_password    => 'glance_dba',
    glance_user           => 'admin',
    glance_user_password  => 'secrete',
    glance_tenant         => 'admin',
    purge_nova_config     => false,
    libvirt_type          => 'kvm',
    nova_volume           => 'nova-volumes',
    iscsi_ip_address      => '10.77.0.1',
    verbose               => true,
    package_ensure        => 'latest',
    folsom_nova_conf      => {
      allow_resize_to_same_host => true,
      buckets_path              => '/var/lib/nova/buckets',
      compute_driver            => 'gpu.GPULibvirtDriver',
      compute_scheduler_driver  => 'nova.scheduler.filter_scheduler.FilterScheduler',
      ec2_dmz_host              => '65.114.169.144',
      ec2_private_dns_show_ip   => true,
      fixed_ip_disassociate_timeout => '600',
      flat_network_dns          => '10.77.0.1',
      instance_name_template    => 'instance-%08x',
      instance_type_extra_specs => 'cpu_arch:x86_64',
      instances_path            => '/var/lib/nova/instances',
#      keystone_ec2_url          => "http://65.114.169.250:5000/v2.0/ec2tokens",
      keystone_ec2_url          => "http://127.0.0.1:5000/v2.0/ec2tokens",
      libvirt_use_virtio_for_bridges => true,
      logging_context_format_string => '%(asctime)s %(levelname)s %(name)s [%(request_id)s %(user_name)s %(project_name)s] %(instance)s%(message)s',
      max_nbd_devices           => '16',
      multi_host                => false,
      my_ip                     => '10.77.0.1',
#      my_ip                     => '127.0.0.1',
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
      vlan_interface            => eth0,
      volume_name_template      => 'volume-%s',
      xvpvncproxy_base_url      => 'http://10.77.0.1:6081/console' },

    require               => Package['dodcs-openstack'],    
  }

  class { 'dodcs-postproc':
    stage   => last,
    require => Class['openstack::all'],
  }

}
