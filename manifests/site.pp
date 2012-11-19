$puppetserver = 'bespin102.east.isi.edu'

#include custom

node default {
  notify { 'I can connect!': }
  import 'defaults.pp'
}
  
import 'friday.pp'
#import 'alchemist03.pp'

# Puppet development and automated test setups for Folsom.
# 103 => lxc
# 250 => kvm
import 'bespin103.pp'
import 'bespin250.pp'
