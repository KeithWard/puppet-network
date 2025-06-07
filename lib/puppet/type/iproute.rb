# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'iproute',
  docs: <<-EOS,
@summary Manage IP routes using iproute2.
@example Add a static route
  iproute { '192.168.2.0/24': 
    ensure => 'present',
    via    => '192.168.1.1',
    dev    => 'eth0',
  }
@example Add a route to a specific table
iproute { 'default@100':
    ensure => 'present',
      prefix=> 'default',
      via   => ' 192.168.1.1'
      dev   => 'eth0',
      table  => '100',
    }


This type provides Puppet with the capabilities to manage routes using `iproute`.

**Autorequires**:
* `Package[iproute2]`
EOS
  features: [],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether this route should be present or absent.',
      default: 'present',
    },
    prefix: {
      type: 'Variant[Stdlib::IP::Address,Enum["default"]]',
      desc: 'The prefix to manage e.g. 192.168.1.0/24 or default. If prefix is omitted, the title will be parsed as the prefix. For multi-table setups, ensure both prefix and table are explicitly specified.',
      behaviour: :namevar,
    },
    via: {
      type: 'Optional[Stdlib::IP::Address]',
      desc: 'The gateway address to use for this route.',
    },
    dev: {
      type: 'Optional[String]',
      desc: 'The output network device to use for this route.',
    },
    metric: {
      type: 'Optional[Integer]',
      desc: 'The metric for the route.',
    },
    table: {
      type: 'Variant[String, Integer]',
      desc: 'The routing table to use for this route.',
      behaviour: :namevar,
    },
    scope: {
      type: 'Optional[Variant[String,Integer]]',
      desc: 'The scope of the route.',
    },
    proto: {
      type: 'Optional[Variant[Enum["kernel", "boot", "static"],Integer]]',
      desc: 'The protocol the route belongs to.',
    },    
    src: {
      type: 'Optional[Stdlib::IP::Address]',
      desc: 'The preferred source address for this route.',
    },
    onlink: {
      type: 'Optional[Boolean]',
      desc: 'whether the next-hop should be treated as on-link.',
    },
    type: {
      type: 'Optional[Enum[unicast, blackhole, unreachable, prohibit, local, broadcast, multicast, throw]]',
      desc: 'Route type.',
    },
  },
)
