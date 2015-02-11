define cumulus_ports::speeds(
  $speed_10g = [],
  $speed_40g = [],
  $speed_40g_div_4 = [],
  $speed_4_by_10g = []
) {
  case $::operatingsystem {
    CumulusLinux : { $supported = true }
    default: { fail("The ${module_name} module is not supported by ${::operatingsystem} based systems") }
  }

  file { '/etc/cumulus':
    ensure => directory,
    mode => '0700',
    before => File['/etc/cumulus/ports.conf'],
  }
  file { '/etc/cumulus/ports.conf':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0600',
    content => template('cumulus_ports/ports.conf.erb')
  }
}
