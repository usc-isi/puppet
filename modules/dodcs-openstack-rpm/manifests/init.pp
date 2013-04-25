# 
# Class to encapsulate the dodcs-openstack package to allow it to be staged.
#

class dodcs-openstack-rpm (
  $package_ensure = present
  ) {

  package { 'dodcs-openstack':
    ensure  => $package_ensure,
  }

}
