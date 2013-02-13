# Configuration for a glance service

######## BEGIN GLANCE ##########
class { 'openstack::glance':
  verbose                   => $verbose,
  db_type                   => $db_type,
  db_host                   => $db_host,
  glance_db_user            => $glance_db_user,
  glance_db_dbname          => $glance_db_dbname,
  glance_db_password        => $glance_db_password,
  glance_user_password      => $glance_user_password,
  enabled                   => $enabled,
  keystone_host             => $keystone_host_public,
  auth_uri                  => "http://${keystone_host}:5000/v2.0/",
}
