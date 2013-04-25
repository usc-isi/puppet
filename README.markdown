# Puppet Modules for DODCS Folsom

The modules in this repository were used to install the DODCS release of
OpenStack Folsom. They were derived from a set of Puppet Labs modules intended
for use on Ubuntu systems for the OpenStack Essex release.

These represent an early effort and should not be considered authoritative.

## Puppet Version

The version of Puppet used with these modules was 2.6, while the Puppet Labs
modules were written expecting Puppet 2.7. The "custom" module is a plug-in
that allowed the 2.6 release to process the modules.

## DODCS-Specific

The modules with the prefix "dodcs-" are specific to the DODCS release.

## Daily Build Cycle

These modules were only used internally on system designated as automated
testing hosts. These hosts also ran Tempest tests, but Tempest is not supported
in these modules.

## Examples

The directory named examples contains some sample node definitions that used
these modules.
