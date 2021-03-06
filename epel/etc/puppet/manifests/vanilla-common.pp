####### shared variables ##################


# this section is used to specify global variables that will
# be used in the deployment of multi and single node openstack
# environments

# MySQL
$db_type                = 'mysql'
$mysql_root_password    = 'dbsecrete'
$mysql_bind_address     = '0.0.0.0'
$mysql_account_security = true
$allowed_hosts          = '%'
$db_host                = '10.0.5.9'


# assumes that eth0 is the public interface
$public_interface  = 'eth0'
# assumes that eth1 is the interface that will be used for the vm network
# this configuration assumes this interface is active but does not have an
# ip address allocated to it.
$private_interface = 'eth1'
# switch this to true to have all service log at verbose
#$verbose              = 'false'
$verbose              = 'true'

# credentials
$admin_email               = 'root@localhost'

#$rabbit_password           = 'dbsecrete'
$rabbit_password           = 'd0dcSdba'  # Old bespin103
#$rabbit_user               = 'openstack_rabbit_user'
$rabbit_user               = 'nova'      # Old bespin103
$rabbit_virtual_host       = '/'

$quantum_admin_password    = 'servicepass'
$quantum_admin_tenant_name = 'services'
$quantum_admin_username    = 'quantum'

$keystone_admin_token      = '999888777666'
$keystone_admin_user       = 'admin'
$keystone_admin_tenant     = 'admin'
$keystone_admin_password   = 'secrete'
$keystone_db_user          = 'keystone'
$keystone_db_password      = 'keystone_dba'
$keystone_db_dbname        = 'keystone'

$glance_db_user            = 'glance'
$glance_db_password        = 'glance_dba'
$glance_db_dbname          = 'glance'
$glance_user_password      = $glance_db_password

$nova_db_user              = 'nova'
$nova_db_password          = 'nova_dba'
$nova_db_dbname            = 'nova'
$nova_user_password        = 'secrete'
$purge_nova_config         = false

$cinder                    = true
$cinder_db_user            = 'cinder'
$cinder_db_password        = 'cinder_dba'
$cinder_db_dbname          = 'cinder'

$quantum                   = true
$quantum_db_user           = 'quantum'
$quantum_db_password       = $quantum_admin_password
$quantum_db_dbname         = 'quantum'
$quantum_sql_connection    = "mysql://${quantum_db_user}:${quantum_db_password}@${db_host}/${quantum_db_dbname}?charset=utf8"

$region                    = 'RegionOne'

$linux_bridge                     = true
$linux_bridge_tenant_network_type = 'vlan'
$linux_bridge_network_vlan_ranges = "physnet1:1000:2999"
$linux_bridge_physical_interface  = 'eth1'
$linux_bridge_physical_interface_mappings = 'physnet1:eth1'

#### end shared variables #################


# multi-node specific parameters

$keystone_host_address   = '10.0.5.4'
$keystone_host_public    = $keystone_host_address
$keystone_host_internal  = $keystone_host_address
$keystone_auth_url       = "http://${keystone_host_public}:5000/v2.0/"

$glance_host_address  = '10.0.5.4'
$glance_host_public   = $glance_host_address
$glance_host_internal = $glance_host_address

$quantum_host_address  = '10.0.5.6'
$quantum_host_public   = $quantum_host_address
$quantum_host_internal = $quantum_host_address


$fixed_network_range  = '10.106.0.0/16' # DODCS: What is reasonable value?


$cinder_host_address  = '10.0.5.5'
$cinder_host_public   = $cinder_host_address
$cinder_host_internal = $cinder_host_address

$nova_host_address   = '10.0.5.3'
$nova_host_public    = $nova_host_address
$nova_host_internal  = $nova_host_address
$nova_sql_connection = "mysql://${nova_db_user}:${nova_db_password}@${db_host}/nova"

$quantum_server_host = $nova_host_address

$rabbit_host = '10.0.5.3'
#$rabbbit_connection = '10.67.0.1' # this is the bridge on bespin103
$rabbit_connection = $rabbit_host
