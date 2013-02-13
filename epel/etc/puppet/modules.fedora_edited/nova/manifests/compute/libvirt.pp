class nova::compute::libvirt (
  $libvirt_type = 'kvm',
  $flat_network_bridge = 'br100',
  $flat_network_bridge_ip,
  $flat_network_bridge_netmask
) {
  nova_config { 'DEFAULT/libvirt_type': value => $libvirt_type }
  nova::network::bridge { $flat_network_bridge:
    ip      => $flat_network_bridge_ip,
    netmask => $flat_network_bridge_netmask,
  }
}
