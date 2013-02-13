# unzip swig screen parted curl euca2ools - extra packages
class nova::utilities (
  package_ensure = 'present'
  ) {
  # YUM behaving oddly when setting euca2ools ensure to 'latest'
  # ignore the class value until why is understood.
  package { 'euca2ools':
    ensure => present,
  }
  package { ['unzip', 'screen', 'parted', 'curl']:
    ensure => present
  }
}
