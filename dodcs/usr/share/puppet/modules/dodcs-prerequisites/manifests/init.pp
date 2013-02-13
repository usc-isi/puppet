# dodcs-prerequisites
#
# Packages required before DODCS OpenStack can be installed.
# ------------------------------------------------------------------- #

class dodcs-prerequisites (
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
