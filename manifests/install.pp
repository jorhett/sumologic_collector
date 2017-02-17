# Class: sumologic_collector::install
# ===================================
#
# Installs and configures the Sumo Logic collector.
#
# Parameters
# ----------
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# * `package_available`
#  Whether or not to install from package (default os-specific)
#
# * `download_url`
#  Defaults to os-specific sumologic location
#
# Examples
# --------
#
# @example
#    classses: 
#      - sumologic_collector
#
#     sumologic_collector::accessid: '12345'
#     sumologic_collector::accesskey: 'fa6e6e4'
#
# Authors
# -------
#
# Jo Rhett https://forge.puppet.com/jorhett
#
# Copyright
# ---------
#
# Copyright 2017 Net Consonance
#
class sumologic_collector {
  String  $version               = 'latest',
  Boolean $remove_manual_install = false,
  Boolean $package_available     = false,
  String  $installation_path     = '/opt/SumoCollector',
) {
  unless ($accessid != undef and $accesskey != undef) {
    fail('You must provide both the accessid and an accesskey for the Sumo Logic collector to register.')
  }

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
      file { '/usr/local/sumo':
        ensure => 'directory',
        owner  => 'root',
        group  => 'root',
      }

      exec { 'Download SumoCollector Package':
        command => '/usr/bin/curl -o /usr/local/sumo/sumocollector.deb -q https://collectors.sumologic.com/rest/download/deb/64',
        creates => '/usr/local/sumo/sumocollector.deb',
        require => File['/usr/local/sumo'],
      }
      package { 'sumocollector':
        ensure   => $version,
        provider => 'dpkg',
        source   => '/usr/local/sumo/sumocollector.deb',
        require  => Exec['Download SumoCollector Package'],
      }
    }
    else if $facts['os']['family'] == 'RedHat' {
      package { 'sumocollector':
        ensure   => $version,
        provider => 'rpm',
        source   => '/usr/local/sumo/sumocollector.deb',
        require  => Exec['Download SumoCollector Package'],
      }
    }
  }
  else {
    fail('Not doing manual installations yet.')
  }

  service { 'collector':
    ensure    => running,
    enable    => true,
    require   => Package['sumocollector'],
    subscribe => File[$sources_path],
  }
}
