# Puppet Modules for OpenStack Folsom Release

These Puppet modules are used to install the main OpenStack Folsom services on
either a single node or on multiple nodes. The standard Puppet modules for
OpenStack are a snapshot from January 2013 of the modules used for Folsom. They
are not derived from the fiels in the "hpc-folsom" branch.

## ISI Module

The class isi::params provides a parameter set that can be used to create the
various resources of an OpenStack installation. By creating this class with the
settings unique to a particular site, the other resources may be created, often
without providing additional parameters.

Other classes in the ISI module either access the standard Puppet classes for
OpenStack services or act as a wrapper for the Puppet Labs Openstack module.

For examples, see the example directory of the ISI module.
