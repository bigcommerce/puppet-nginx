# Class to manage nginx site upstreams
define nginx::upstream::member(
  $upstream,
  $ensure       = 'present',
  $host         = '',
  $down         = false,
  $weight       = 1,
  $max_fails    = 0,
  $fail_timeout = 0,
  $backup       = false
) {

  $use_host = $host ? {
    ''      => $name,
    default => $host,
  }
  $member_path = "/etc/nginx/upstreams.d/${upstream}/1_${name}.conf"
  file { $member_path:
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nginx/upstream.member.erb'),
    notify  => Exec["rebuild-nginx-upstream-${upstream}"],
    require => File["/etc/nginx/upstreams.d/${upstream}/"]
  }
}
