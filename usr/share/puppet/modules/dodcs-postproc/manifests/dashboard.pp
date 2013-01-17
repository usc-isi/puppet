# dashboard.pp
#
# DODCS setup for Horizon

class dodcs-postproc::dashboard (
  $wsgi_conf = '/etc/httpd/conf.d/wsgi.conf',
  $dashb_dir = '/etc/openstack-horizon'
) {

  file {"$dashb_dir":
    ensure  => directory,
    # should already be there from main stage
    require => Package['openstack-dashboard'],
  }

  file { 'wsgi_conf':
    path   => $wsgi_conf,
    ensure => present,
    source => "puppet:///modules/dodcs-postproc/wsgi.conf.isi",
  }

  file { "${dashb_dir}/openstack_dashboard":
    ensure => directory,
  }

  file { "${dashb_dir}/openstack_dashboard/local":
    ensure => directory,
    owner  => 'apache',
    group  => 'apache',
    require => File["${dashb_dir}/openstack_dashboard"],
  }

  file { 'set_db_owner':
    path    => "${dashb_dir}/openstack_dashboard/local/dashboard_openstack.sqlite3",
    owner   => 'apache',
    group   => 'apache',
    require => File["${dashb_dir}/openstack_dashboard"],
  }

  exec {'set_static_owner':
    command => "chown -R apache:apache ${dashb_dir}/static",
    require => Exec['horizon_syncdb'],
  }

  exec {'horizon_syncdb':
    command => "python ${dashb_dir}/manage.py syncdb --noinput",
# TODO: Can this always run or should some conditions stop it?
#    unless  => "ls -ld ${dashb_dir}/openstack_dashboard/local/dashboard_openstack.sqlite3 | grep -q apache",
    notify  => Exec['set_static_owner'],
  }
}
