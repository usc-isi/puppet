# This class is used to specify configuration parameters that are common
# across all nova services.
#
# ==Parameters
#
# [sql_connection] Connection url to use to connect to nova sql database.
#  If specified as false, then it tries to collect the exported resource
#   Nova_config <<| title == 'sql_connection' |>>. Optional. Defaults to false. 
# [image_service] Service used to search for and retrieve images. Optional.
#   Defaults to 'nova.image.local.LocalImageService'
# [glance_api_servers] List of addresses for api servers. Optional.
#   Defaults to localhost:9292.
# [rabbit_host] Location of rabbitmq installation. Optional. Defaults to localhost.
# [rabbit_password] Password used to connect to rabbitmq. Optional. Defaults to guest.
# [rabbit_port] Port for rabbitmq instance. Optional. Defaults to 5672.
# [rabbit_userid] User used to connect to rabbitmq. Optional. Defaults to guest.
# [rabbit_virtual_host] The RabbitMQ virtual host. Optional. Defaults to /.
# [auth_strategy]
# [service_down_time] maximum time since last check-in for up service. Optional.
#  Defaults to 60
# [logdir] Directory where logs should be stored. Optional. Defaults to '/var/log/nova'.
# [state_path] Directory for storing state. Optional. Defaults to '/var/lib/nova'.
# [lock_path] Directory for lock files. Optional. Distro specific default.
# [verbose] Rather to print more verbose output. Optional. Defaults to false.
# [periodic_interval] Seconds between running periodic tasks. Optional.
#   Defaults to '60'.
# [report_interval] Interval at which nodes report to data store. Optional.
#    Defaults to '10'.
# [root_helper] Command used for roothelper. Optional. Distro specific.
#
class nova(
  # this is how to query all resources from our clutser
  $nova_cluster_id='localcluster',
  $sql_connection = false,
  $image_service = 'nova.image.glance.GlanceImageService',
  # these glance params should be optional
  # this should probably just be configured as a glance client
  $glance_api_servers = 'localhost:9292',
  $rabbit_host = 'localhost',
  $rabbit_password='guest',
  $rabbit_port='5672',
  $rabbit_userid='guest',
  $rabbit_virtual_host='/',
  $auth_strategy = 'keystone',
  $service_down_time = 60,
  $logdir = '/var/log/nova',
  $state_path = '/var/lib/nova',
  $lock_path = $::nova::params::lock_path,
  $verbose = false,
  $periodic_interval = '60',
  $report_interval = '10',
  $root_helper = $::nova::params::root_helper,
  $package_ensure = 'present',
  $nova_ca_path = '/var/lib/nova/CA',
  $folsom_nova_conf = {}
) inherits nova::params {

  # all nova_config resources should be applied
  # after the nova common package
  # before the file resource for nova.conf is managed
  # and before the post config resource
  Nova_config<| |> {
    require +> Package['nova-common'],
    before  +> File['/etc/nova/nova.conf'],
    notify  +> Exec['post-nova_config']
  }

  File {
    require => Package['nova-common'],
    owner   => 'nova',
    group   => 'nova',
  }

  # TODO - see if these packages can be removed
  # they should be handled as package deps by the OS
  package { 'python':
    ensure => present,
  }
  package { 'python-greenlet':
    ensure => present,
    require => Package['python'],
  }

  class { 'nova::utilities':
    package_ensure => $package_ensure,
  }

  # this anchor is used to simplify the graph between nova components by
  # allowing a resource to serve as a point where the configuration of nova begins
  anchor { 'nova-start': }

  package { "python-nova":
    ensure  => $package_ensure,
    require => Package["python-greenlet"]
  }

  package { 'nova-common':
    name    => $::nova::params::common_package_name,
    ensure  => $package_ensure,
    require => [Package["python-nova"], Anchor['nova-start']]
  }

  group { 'nova':
    ensure  => present,
    system  => true,
    require => Package['nova-common'],
  }
  user { 'nova':
    ensure  => present,
    gid     => 'nova',
    system  => true,
    require => Package['nova-common'],
  }

  file { $logdir:
    ensure  => directory,
    mode    => '0751',
  }
  file { '/etc/nova/nova.conf':
    mode  => '0640',
  }

  # *** Comment Below from Puppet Labs, not DODCS. ***
  # I need to ensure that I better understand this resource
  # this is potentially constantly resyncing a central DB
  exec { "nova-db-sync":
    command     => "/usr/bin/nova-manage db sync",
#    refreshonly => "true",
    refreshonly => "false",
    require     => [Package['nova-common'], Nova_config['sql_connection']],
  }

  # used by debian/ubuntu in nova::network_bridge to refresh
  # interfaces based on /etc/network/interfaces
  exec { "networking-refresh":
    command     => "/sbin/ifdown -a ; /sbin/ifup -a",
    refreshonly => "true",
  }

  
  # both the sql_connection and rabbit_host are things
  # that may need to be collected from a remote host
  if $sql_connection {
    nova_config { 'sql_connection': value => $sql_connection }
  } else {
    Nova_config <<| title == 'sql_connection' |>>
  }

  nova_config { 'image_service': value => $image_service }

  if $image_service == 'nova.image.glance.GlanceImageService' {
    if $glance_api_servers {
      nova_config { 'glance_api_servers': value => $glance_api_servers }
    } else {
      # TODO this only supports setting a single address for the api server
      Nova_config <<| title == glance_api_servers |>>
    }
  }

  nova_config { 'auth_strategy': value => $auth_strategy }

  if $auth_strategy == 'keystone' {
    nova_config { 'use_deprecated_auth': value => false }
  } else {
    nova_config { 'use_deprecated_auth': value => true }
  }


  if $rabbit_host {
    nova_config { 'rabbit_host': value => $rabbit_host }
  } else {
    Nova_config <<| title == 'rabbit_host' |>>
  }
  # I may want to support exporting and collecting these
  nova_config {
    'rabbit_password': value => $rabbit_password;
    'rabbit_port': value => $rabbit_port;
    'rabbit_userid': value => $rabbit_userid;
    'rabbit_virtual_host': value => $rabbit_virtual_host;
  }


  nova_config {
    'verbose': value => $verbose;
    'logdir': value => $logdir;
    # Following may need to be broken out to different nova services
    'state_path': value => $state_path;
    'lock_path': value => $lock_path;
    'service_down_time': value => $service_down_time;
    'root_helper': value => $root_helper;
    'ca_path': value => $nova_ca_path;
  }

  
#   # DODCS Folsom
#   # Should be a better way, but I don't know it yet.
#   $allow_resize_to_same_host = $folsom_nova_conf['allow_resize_to_same_host']
#   $buckets_path = $folsom_nova_conf['buckets_path']
#   $compute_driver = $folsom_nova_conf['compute_driver']
#   $compute_scheduler_driver = $folsom_nova_conf['compute_scheduler_driver']
#   $ec2_dmz_host = $folsom_nova_conf['ec2_dmz_host']
#   $ec2_private_dns_show_ip = $folsom_nova_conf['ec2_private_dns_show_ip']
#   $fixed_ip_disassociate_timeout = $folsom_nova_conf['fixed_ip_disassociate_timeout']
#   $flat_network_dns = $folsom_nova_conf['flat_network_dns']
#   $instance_name_template = $folsom_nova_conf['instance_name_template']
#   $instance_type_extra_specs = $folsom_nova_conf['instance_type_extra_specs']
#   $instances_path = $folsom_nova_conf['instances_path']
#   $keystone_ec2_url = $folsom_nova_conf['keystone_ec2_url']
#   $libvirt_use_virtio_for_bridges = $folsom_nova_conf['libvirt_use_virtio_for_bridges']
#   $logging_context_format_string = $folsom_nova_conf['logging_context_format_string']
#   $max_nbd_devices = $folsom_nova_conf['max_nbd_devices']
#   $multi_host = $folsom_nova_conf['multi_host']
#   $my_ip = $folsom_nova_conf['my_ip']
#   $network_size = $folsom_nova_conf['network_size']
#   $networks_path = $folsom_nova_conf['networks_path']
#   $osapi_compute_extension = $folsom_nova_conf['osapi_compute_extension']
# #  $periodic_interval = $folsom_nova_conf['periodic_interval']
#   $pybasedir = $folsom_nova_conf['pybasedir']
#   $quota_cores = $folsom_nova_conf['quota_cores']
#   $quota_gigabytes = $folsom_nova_conf['quota_gigabytes']
#   $quota_ram = $folsom_nova_conf['quota_ram']
#   $quota_volumes = $folsom_nova_conf['quota_volumes']
#   $rootwrap_config = $folsom_nova_conf['rootwrap_config']
#   $send_arp_for_ha = $folsom_nova_conf['send_arp_for_ha']
#   $states_path = $folsom_nova_conf['states_path']
#   $vlan_interface = $folsom_nova_conf['vlan_interface']
#   $volume_name_template = $folsom_nova_conf['volume_name_template']
#   $use_cow_images = $folsom_nova_conf['use_cow_images']
#   $xvpvncproxy_base_url = $folsom_nova_conf['xvpvncproxy_base_url']

#   nova_config {
#     'allow_resize_to_same_host': value => $allow_resize_to_same_host;
#     'buckets_path': value => $buckets_path;
#     'compute_driver': value => $compute_driver;
#     'compute_scheduler_driver': value => $compute_scheduler_driver;
#     'ec2_dmz_host': value => $ec2_dmz_host;
#     'ec2_private_dns_show_ip': value => $ec2_private_dns_show_ip;
#     'fixed_ip_disassociate_timeout': value => $fixed_ip_disassociate_timeout;
#     'flat_network_dns': value => $flat_network_dns;
#     'instance_name_template': value => $instance_name_template;
#     'instance_type_extra_specs': value => $instance_type_extra_specs;
#     'instances_path': value => $instances_path;
#     'keystone_ec2_url': value => $keystone_ec2_url;
#     'libvirt_use_virtio_for_bridges': value => $libvirt_use_virtio_for_bridges;
#     'logging_context_format_string': value => $logging_context_format_string;
#     'max_nbd_devices': value => $max_nbd_devices;
#     'multi_host': value => $multi_host;
#     'my_ip': value => $my_ip;
#     'network_size': value => $network_size;
#     'networks_path': value => $networks_path;
#     'osapi_compute_extension': value => $osapi_compute_extension;
#     'periodic_interval': value => $periodic_interval;
#     'pybasedir': value => $pybasedir;
#     'quota_cores': value => $quota_cores;
#     'quota_gigabytes': value => $quota_gigabytes;
#     'quota_ram': value => $quota_ram;
#     'quota_volumes': value => $quota_volumes;
#     'rootwrap_config': value => $rootwrap_config;
#     'send_arp_for_ha': value => $send_arp_for_ha;
#     'states_path': value => $states_path;
#     'vlan_interface': value => $vlan_interface;
#     'volume_name_template': value => $volume_name_template;
#     'xvpvncproxy_base_url': value => $xvpvncproxy_base_url;
#   }

#   if $use_cow_images != undef {
#     nova_config {
#       'use_cow_images': value => $use_cow_images;
#     }
#   }

  exec { 'post-nova_config':
    command => '/bin/echo "Nova config has changed"',
    refreshonly => true,
  }

}
