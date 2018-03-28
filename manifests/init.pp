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
#     sumologic_collector::config::accessid: '12345'
#     sumologic_collector::config::accesskey: 'fa6e6e4'
#
class sumologic_collector() {
  contain ::sumologic_collector::package
  contain ::sumologic_collector::config
  contain ::sumologic_collector::service

  Class['sumologic_collector::package'] -> Class['sumologic_collector::config'] -> Class['sumologic_collector::service']
}
