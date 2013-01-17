#
# used to configure qpid notifications for glance
#
class glance::notify::rabbitmq(
  # TODO be able to pass in rabbitmq params
) inherits glance::api {

  class { 'glance::notify':
    notifier_strategy => 'rabbit',
  }

## DODCS
# Quick hack to get these in for Folsom
##
  glance::api::config { 'rabbitmq':
    config => {
      rabbit_host     => "$::openstack::all::rabbit_host",
      rabbit_port     => 5672
      rabbit_use_ssl  => false
      rabbit_userid   => "$::openstack::all::rabbit_userid",
      rabbit_password => "::openstack::all::rabbit_password"
    },
    order  => '07',
  }
}
