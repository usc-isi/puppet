# == Class: isi::dodcs::prerequisites
#
# Packages required before DODCS OpenStack can be installed. Puppet stages
# should be defined such that Puppet processes this class before any others.
#
# === Parameters
#
# [package_ensure] Code for the state Puppet should expect for this package. Optional. Default present.
#
# === Examples
#
#  class { 'isi::dodcs::prerequisites':
#    stage => first,
#  }
#
# === Authors
#
# Craig E. Ward <cward@isi.edu>
#
class isi::dodcs::prerequisites (
  $package_ensure = present
  ) {

  package { 'glibc-devel':
    ensure => $package_ensure,
  }

  package { 'automake':
    ensure => $package_ensure,
  }

  package { 'gcc':
    ensure => $package_ensure,
  }

  package { 'gcc-c++':
    ensure => $package_ensure,
  }

}
                            
