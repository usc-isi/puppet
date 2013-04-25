# == Class: isi::dodcs::openstack
#
# Class to install the dodcs-openstack package and allow it to be staged. The
# stage that Puppet should place this package must be before the main Puppet
# stage.
#
# The dodcs-openstack package for Folsom writes very view files, but pulls in
# most of the rest of OpenStack by setting up dependencies for yum to
# process. Later resources defined in Puppet should detect these packages as
# present and not install them again, but only configure them.
#
# === Parameters
#
# [package_name  ] Name of the RPM package for yum to install. Optional. Default dodcs-openstack.
# [package_ensure] Code for the state Puppet should expect for this package. Optional. Default present.
#
# === Examples
#
#  class {'isi::dodcs::openstack':
#    stage => before_main,
#  }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::dodcs::openstack (
  $package_name   = 'dodcs-openstack',
  $package_ensure = present
  ){

  package { "$package_name":
    ensure  => $package_ensure,
  }

}
          
