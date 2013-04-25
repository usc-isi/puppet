#
# Creates an auth file that can be used to export
# environment variables that can be used to authenticate
# against a keystone server.
#
class openstack::auth_file(
  $admin_password,
  $controller_node      = '127.0.0.1',
  $keystone_admin_token = 'keystone_admin_token',
  $admin_user           = 'admin',
  $admin_tenant         = 'openstack',
  $ec2_port             = '8773',
  $openrc               = '/root/openrc'
) {

  file { "${openrc}":
    content =>
  "
export OS_TENANT_NAME=${admin_tenant}
export OS_USERNAME=${admin_user}
export OS_PASSWORD=${admin_password}
export OS_AUTH_URL=\"http://${controller_node}:5000/v2.0/\"
export OS_AUTH_STRATEGY=keystone
# DODCS (Folsom)
export EC2_URL=http://${controller_node}:${ec2_port}/services/Cloud
export EC2_PRIVATE_KEY=pk.pem
export EC2_CERT=cert.pem
export NOVA_CERT=cacert.pem
export EUCALYPTUS_CERT=\${NOVA_CERT}
"
# DODCS
#  export SERVICE_TOKEN=${keystone_admin_token}
#  export SERVICE_ENDPOINT=http://${controller_node}:35357/v2.0/
    
  }

  file { 'finish_openrc.sh':
    ensure  => present,
    path    => '/root/finish_openrc.sh',
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
    content => template('openstack/finish_openrc.sh.erb'),
    require => [ Class['keystone'], File['initial_data.sh'], File["${openrc}"] ],
  }

  exec { 'run_finish_openrc':
    command   => "/root/finish_openrc.sh",
    subscribe => File['finish_openrc.sh'],
    unless    => "grep EC2_ACCESS_KEY ${openrc}",
  }
    
}
