define cumulus_ports::speeds(
  $speed_10g = [],
  $speed_40g = [],
  $speed_40g_div_4 = [],
  $speed_10g_by_4 = []
) {
  case $::operatingsystem {
    CumulusLinux : { $supported = true }
    default: { fail("The ${module_name} module is not supported by ${::operatingsystem} based systems") }
  }

  file { '/etc/cumulus':
    ensure => directory,
    mode => 0700,
    before => File['/etc/cumulus/ports.conf'],
  }
  file { '/etc/cumulus/ports.conf':
    ensure => file,
    owner => 0,
    group => 0,
    mode => '0600',
    content => template('cumulus_ports/ports.conf.erb')
  }
}
