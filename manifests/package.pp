# Class: sumologic_collector::package
#
# @summary Installs the Sumo Logic collector.
#
# @example
#    classses: 
#      - 'sumologic_collector::package'
#
#     sumologic_collector::accessid: '12345'
#     sumologic_collector::accesskey: 'fa6e6e4'
# ===================================
#
# Installs the Sumo Logic collector.
#
class sumologic_collector::package(
  String  $package_name,
  String  $version,
  String  $collector_source,
  Boolean $remove_manual_install,
  Boolean $package_available,
  String  $installation_path,
) {

  # Determite bits
  $os_arch_bits = $facts['os']['architecture'] ? {
    'x86'    => '32',
    'amd64'  => '64',
    'x86_64' => '64',
    default  => '64',
  }

  # Unless the sumo package is installed, kill off the sumo collector
  if $remove_manual_install {
    exec { 'remove-manual-collector-installation':
      path    => '/bin:/usr/bin',
      command => "${installation_path}/uninstall -q",
      onlyif  => "test -f ${installation_path}/uninstall",
    }
  }

  if $package_available {
    if $facts['os']['family'] == 'Debian' {
      exec { 'Download SumoCollector Package':
        command => "/usr/bin/curl -o /tmp/sumocollector.deb -q ${collector_source}/deb/${os_arch_bits}",
        creates => '/tmp/sumocollector.deb',
      }
      package { $package_name:
        ensure   => $version,
        provider => 'dpkg',
        source   => '/tmp/sumocollector.deb',
        require  => Exec['Download SumoCollector Package'],
      }
    }
    elsif $facts['os']['family'] == 'RedHat' {
      package { $package_name:
        ensure   => $version,
        provider => 'rpm',
        source   => "${collector_source}/rpm/${os_arch_bits}",
      }
    }
  }
  else {
    fail('Manual installation not supported yet.')
  }
}
