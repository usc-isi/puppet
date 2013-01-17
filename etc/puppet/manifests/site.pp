$puppetserver = 'bespin109.east.isi.edu'

#include custom

node default {
  notify { 'I can connect!': }
  import 'defaults.pp'
}
  
# Puppet development and automated test setups for Folsom.
# 108 => kvm 
#import 'bespin108.pp'
import 'bespin108_shared.pp'
import 'bespin108_controller.pp'
import 'bespin111_compute.pp'
