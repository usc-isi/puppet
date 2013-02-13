####### shared variables ##################


# this section is used to specify global variables that will
# be used in the deployment of multi and single node openstack
# environments

# assumes that eth0 is the public interface
$public_interface  = 'eth0'
# assumes that eth1 is the interface that will be used for the vm network
# this configuration assumes this interface is active but does not have an
# ip address allocated to it. 
$private_interface = 'eth1'
# credentials
$admin_email          = 'root@localhost'
$admin_password       = 'secrete'
$keystone_db_password = 'keystone_dba'
$keystone_admin_token = '999888777666'
$nova_db_password     = 'nova_secrete'
$nova_user_password   = 'secrete'
$glance_db_password   = 'glance_dba'
$glance_user_password = 'secrete'
$rabbit_password      = 'dbsecrete'
$rabbit_user          = 'openstack_rabbit_user'
$fixed_network_range  = '10.108.0.0/16'
# switch this to true to have all service log at verbose
#$verbose              = 'false'
$verbose              = 'true'


#### end shared variables #################

# multi-node specific parameters

$controller_node_address  = '10.0.5.8'

$controller_node_public   = $controller_node_address
$controller_node_internal = $controller_node_address 
$sql_connection         = "mysql://nova:${nova_db_password}@${controller_node_internal}/nova"
