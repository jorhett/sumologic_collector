# Class: sumologic_collector
#
# A description of what this class does
#
# @summary Installs and configures the Sumo Logic collector.
#
# @example
#    classses: 
#      - 'sumologic_collector'
#
#     sumologic_collector::accessid: '12345'
#     sumologic_collector::accesskey: 'fa6e6e4'
#
class sumologic_collector::service(
  String $service_name,
  Enum['running','stopped'] $ensure,
  Boolean $enable,
) {
  require ::sumologic_collector::package

  service { $service_name:
    ensure  => $ensure,
    enable  => $enable,
    require => Package[$sumologic_collector::package::package_name],
  }
}
