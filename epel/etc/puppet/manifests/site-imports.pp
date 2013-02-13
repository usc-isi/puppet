$puppetserver = 'bespin109.east.isi.edu'

#include custom

node default {
  notify { 'I can connect!': }
  import 'defaults.pp'
}

# Single-node
#import 'bespin108.pp'
#import 'bespin111.pp'

# Multi-node
import 'vanilla-common.pp'

# import 'keystone-glance-node.pp'
# import 'nova-controller-node.pp'
# import 'cinder-node.pp'

import 'quantum-agent-node.pp'
