# defaults.pp -- Placement of common packages, services, etc.

# The default package just to have something here.
package { 'emacs':
  ensure => present,
}

notify { 'emacs-msg':
  message => "Ensuring emacs",
  require => Package['emacs'],
}

