# nova-float.pp
#
# Issue optional nova-manage float create command. Run on head node for
# a multiple node configuration.
#
# Usage:
#      class { 'dodcs-postproc::nova-float':
#        stage    => last,
#        ip_range => 65.114.169.169/29,
#      }
#
# Change ip_range as appropriate. Not providing a value is an error.
#

class dodcs-postproc::nova-float (
  $ip_range
 ) {

 # This class is expected to run after the main configuration, as
 # part of the stage 'last'.
   exec { 'nova-manage-float':
     command => "nova-manage floating create ${ip_range}",
     refreshonly => true,
   }

 }
