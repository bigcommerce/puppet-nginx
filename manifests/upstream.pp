define nginx::upstream($ensure = 'present', $strategy = '', $keepalive = false) {
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
    ensure => $ensure ? {
      'present' => 'directory',
      'absent'  => 'absent',
    },
    purge   => true,
    recurse => true,
    force   => true,
  }

  file { $target_file:
    replace => false,
    notify  => Exec['reload-nginx'],
  }

  file { "${target_dir}/0_header.conf":
    content => template('nginx/upstream.header.erb'),
  }

  file { "${target_dir}/2_footer.conf":
    content => '}',
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
    notify      => Exec['reload-nginx'],
  }
}