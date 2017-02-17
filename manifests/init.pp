# Class: sumologic_collector
# ===========================
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
  String  $accessid              = undef,
  String  $accesskey             = undef,
  String  $collector_name        = $facts['fqdn'],
  Hash    $sources               = {},
  String  $sources_path          = '/usr/local/sumo/sumo.json',
  String  $sumo_conf_template    = 'sumologic_collector/sumo.conf.epp',
  String  $sumo_json_template    = 'sumologic_collector/sumo.json.epp',
  String  $service_name          = 'collector',
) {
  unless ($accessid != undef and $accesskey != undef) {
    fail('You must provide both the accessid and an accesskey for the Sumo Logic collector to register.')
  }

  contain 'sumologic_collector::install'
  include 'sumologic_collector::install'

  file { '/etc/sumo.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp($sumo_conf_template),
  }

  file { $sources_path:
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp($sumo_json_template),
  }

  service { $service_name:
    ensure    => running,
    enable    => true,
    require   => Package['sumocollector'],
    subscribe => File[$sources_path],
  }
}
