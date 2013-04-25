#
# Setup a vanilla single node Openstack Folsom using the isi::single class.
#
# ------------------------------------------------------------------------- #
node /all-in-one-node/ {

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

  notify { "$::fqdn":
    message => "Running configuration of $::fqdn",
  }

  # This class encapsulates the other resources for a single-node installation.
  class { 'isi::single':
    public_interface        => 'eth0',
    private_interface       => 'eth1',
    mysql_root_password     => 'sql_pass',
    rabbit_password         => 'dbsecrete',
    keystone_db_password    => 'keystone_dba',
    glance_db_password      => 'glance_dba',
    nova_db_password        => 'nova_dba',
    nova_user_password      => 'secrete',
    cinder_db_password      => 'cinder_dba',
    keystone_admin_password => 'keystone_dba',
    quantum_db_password     => 'servicepass',
    quantum_admin_password  => 'servicepass',
    keystone_admin_token    => '999888777666',
    secret_key              => 'horizon_secrete_key',
    horizon                 => false,
  }
}
