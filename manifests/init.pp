# - Class to install and manage nginx
class nginx(
  $package         = 'full',
  $version         = 'installed',
  $config          = '',
  $fastcgi_params  = '',
  $service_ensure  = 'running',
) {

  package { 'nginx':
    ensure => $version,
    name   => "nginx-${package}",
  }

  service { 'nginx':
    ensure     => $service_ensure,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    restart    => '/usr/sbin/nginx -t -c /etc/nginx/nginx.conf && /etc/init.d/nginx reload',
    subscribe  => File['/etc/nginx/nginx.conf'],
  }

  if $service_ensure == 'running' {
    exec { 'reload-nginx':
      command     => '/usr/sbin/nginx -t -c /etc/nginx/nginx.conf && /etc/init.d/nginx reload',
      refreshonly => true,
    }
  }
  else {
    exec { 'reload-nginx':
      command     => true,
      refreshonly => true,
    }
  }

  file { ['/etc/nginx/conf.d/',
    '/etc/nginx/upstreams.d/',
    '/etc/nginx/sites-enabled',
    '/etc/nginx/sites-available']:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['nginx'],
  }

  $use_config = $config ? {
    ''      => 'puppet:///modules/nginx/nginx.conf',
    default => $config,
  }

  file { '/etc/nginx/nginx.conf':
    ensure  => 'present',
    source  => $use_config,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  $use_fastcgi_params = $fastcgi_params ? {
    ''      => 'puppet:///modules/nginx/fastcgi_params',
    default => $fastcgi_params,
  }

  file { '/etc/nginx/fastcgi_params':
    ensure  => 'present',
    source  => $use_fastcgi_params,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['nginx'],
    notify  => Service['nginx'],
  }

  file { '/var/cache/nginx/':
    ensure => 'directory',
    owner  => 'www-data',
    group  => 'www-data',
    mode   => '0750',
  }

  # remove the default site
  nginx::site { 'default':
    ensure => 'absent',
  }
}
