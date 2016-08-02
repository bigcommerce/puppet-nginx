define nginx::upstream(
  $ensure = 'present',
  $strategy = '',
  $keepalive = false,
  $check_health = false,
  $check_interval = '3000',
  $check_rise = 2,
  $check_fall = 5,
  $check_timeout = 1000,
  $check_default_down = true,
  $check_type = 'tcp',
  $check_port = '',
  $check_keepalive_requests = 1,
  $check_http_send = '',
  $check_http_expect_alive = '',
) {

  validate_bool($check_health)
  validate_bool($check_default_down)
  validate_re($check_type, ['^tcp$','^http$','^ssl_hello$','^mysql$','^ajp$','^fastcgi$'])

  $target_dir = "/etc/nginx/upstreams.d/${name}/"
  $target_file = "/etc/nginx/conf.d/upstream_${name}.conf"

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
    ensure => $ensure,
    notify => Exec["rebuild-nginx-upstream-${name}"],
  }

  file { $target_dir:
    ensure  => $ensure ? {
      'present' => 'directory',
      'absent'  => 'absent',
    },
    purge   => true,
    recurse => true,
    force   => true,
  }

  file { $target_file:
    replace => false,
    notify  => Service['nginx'],
  }

  file { "${target_dir}/0_header.conf":
    content => template('nginx/upstream.header.erb'),
  }

  file { "${target_dir}/2_footer.conf":
    content => template('nginx/upstream.footer.erb'),
  }

  $command = $ensure ? {
    'present' => "/bin/sh -c '
      if [ `/usr/bin/find ${target_dir} -maxdepth 1 -type f -name \"1_*.conf\" | wc -l` -gt 0 ]; then
        /usr/bin/find ${target_dir} -maxdepth 1 -type f -name \"*.conf\" -print0 | sort -z | xargs -0 cat >| ${target_file}
      else
        echo '' > ${target_file}
      fi'",
    'absent' => '/bin/true',
  }

  exec { "rebuild-nginx-upstream-${name}":
    command     => $command,
    refreshonly => true,
    require     => File[$target_dir],
    notify      => Service['nginx'],
  }
}
