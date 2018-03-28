# Class: sumologic_collector::config
#
# @summary Configures the Sumo Logic collector.
#
# @example
#    classses: 
#      - 'sumologic_collector'
#
#     sumologic_collector::config::accessid: '12345'
#     sumologic_collector::config::accesskey: 'fa6e6e4'
#
class sumologic_collector::config(
  String[1] $accessid,
  String[1] $accesskey,
  String $collector_name,
  String $sources_path,
  String $source_template,
  Hash   $sources,
  String $properties_template,
  Hash   $properties,
) {
  require ::sumologic_collector::package

  file { '/opt/SumoCollector/config/user.properties':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp($properties_template, {
      collector_name => $collector_name,
      accessid       => $accessid,
      accesskey      => $accesskey,
      sources_path   => $sources_path,
      properties     => $properties,
    }),
  }

  # Create the sources directory
  file { $sources_path:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }
  # Create a file for each sources
  $sources.each |$name, $values| {
    file { "${sources_path}/${name}.json":
      ensure  => $values['ensure'],
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => epp($source_template, {
        name   => $name,
        values => $values,
      }),
    }
  }
}
