#!/bin/bash
# --------------------------------------------------------------------------- #
# Script to create the initial users and tenants for DODCS automated test
# environment.
# --------------------------------------------------------------------------- #
# The command line  arguments should be something like:
#   --token 999888777666 --endpoint http://127.0.0.1:35357/v2.0/
# The token value is assigned to SERVICE_TOKEN and endpoint value to 
# SERVICE_ENDPOINT so that neither is required on the keystone command line.
# --------------------------------------------------------------------------- #

# --------------------------------------------------------------------------- #
# TODO: This doesn't really need to be an erb template file. It could, however,
#       be modified to allow the Puppet manifest to configure the toles, users,
#       and tenants to be created. Initial revision sets up the DODCS automated
#       test environment.
# --------------------------------------------------------------------------- #

#echo "CLI ARGS: $*"
#set -o xtrace
ME=`basename $0`

function usage {
    echo ""
    echo "usage: ${ME} --token token_value --endpoint url_string"
    echo ""
    echo "alternative usage: ${ME} -t token_value -e url_string"
    echo "Unrecoginzed arguments are ignored."
}


if [ -f keystone_shell_functions ] ; then
    . keystone_shell_functions
else
    echo "${ME}: cannot load keystone_shell_functions"
    exit 1
fi

service_token=''
service_endpoint=''

# This optspec allows both "--token" and "-t" style arguments, but not
# "--token=something" style.
# Unrecognized arguments are ignored.
optspec=":ht:e:-:"
while getopts "${optspec}" optchar; do
    case "${optchar}" in
	-)
	    case "${OPTARG}" in
		token)
		    service_token="${!OPTIND}"
		    OPTIND=$(( $OPTIND + 1 ))
		    ;;
		endpoint)
                    service_endpoint="${!OPTIND}"
		    OPTIND=$(( $OPTIND + 1 ))
                    ;;
            esac
	    ;;

	t)
	    service_token=${OPTARG}
	    ;;

	e)
	    service_endpoint=${OPTARG}
	    ;;

	/?)
	    usage;
	    exit 2
	    ;;
    esac
done

if [ -z "${service_token}" -o -z "${service_endpoint}" ] ; then
    echo "ERROR: cannot proceed without service token or service endpoint"
    echo ""
    usage
    exit 3
fi

export SERVICE_TOKEN=${service_token}
export SERVICE_ENDPOINT=${service_endpoint}

# echo "Test: SERVICE_TOKEN=${SERVICE_TOKEN} and SERVICE_ENDPOINT=${SERVICE_ENDPOINT}"
# exit 0

# Roles
adminRole=$(role_create Admin)
memberRole=$(role_create Member)
keystoneServiceAdminRole=$(role_create KeystoneServiceAdmin)
keystoneAdminRole=$(role_create KeystoneAdmin)
project1Role=$(role_create Project1)

# Users
adminUser=$(user_create admin secrete admin@example.com)
demoUser=$(user_create demo demosecrete demo@example.com)
novaUser=$(user_create nova secrete nova@example.com)
glanceUser=$(user_create glance secrete glance@example.com)

# Tenants
adminTenant=$(tenant_create admin "Default admin tenant")
serviceTenant=$(tenant_create service "Default service tenant")
demoTenant=$(tenant_create demo 'Default demo tenant')


$(user_role_add $adminUser $adminRole  $adminTenant)
$(user_role_add $adminUser $adminRole  $serviceTenant)
$(user_role_add $adminUser $adminRole  $demoTenant)

$(user_role_add $adminUser $keystoneServiceAdminRole $adminTenant)
$(user_role_add $adminUser $keystoneAdminRole $adminTenant)

$(user_role_add $demoUser $memberRole $demoTenant)

$(user_role_add $novaUser $adminRole $serviceTenant)
$(user_role_add $glanceUser $adminRole $serviceTenant)

# Tempest support
tempestAdminUser=$(user_create tempestAdmin tpassadmin tempestAdmin@example.com)
tempest1User=$(user_create tempest1 tpass1 tempest1@example.com)
tempest2User=$(user_create tempest2 tpass2 tempest2@example.com)

tempestTenant=$(tenant_create tempest 'Tenant for Tempest automated testing')

$(user_role_add $tempestAdminUser $adminRole $tempestTenant)
$(user_role_add $tempest1User $memberRole $tempestTenant)
$(user_role_add $tempest2User $memberRole $tempestTenant)

# Allow this to run more-than-once and not return a failure.
exit 0
