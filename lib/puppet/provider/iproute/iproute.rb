# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'json'
require 'ipaddr'

class Puppet::Provider::Iproute::Iproute < Puppet::ResourceApi::SimpleProvider
  def get(context)
    @current_state = {}
    routes = route_exec(context, %w[route show table all])
    routes.map do |route|
      prefix = route['dst']
      table = route['table'] || 'main'
      @current_state["#{prefix}@#{table}"] = {
        ensure: 'present',
        prefix: prefix,
        table: table,
        via: route['gateway'],
        dev: route['dev'],
        metric: route['metric'],
        scope: route['scope'],
        proto: route['protocol'],
        src: route['prefsrc'],
        onlink: route.key?('flags') && route['flags'].include?('onlink'),
        type: route['type'],
      }
    end
  end

  def parse_route(should)
    args = []
    args << should[:prefix]
    args += ['via', should[:via]] if should[:via]
    args += ['dev', should[:dev]] if should[:dev]
    args += ['metric', should[:metric].to_s] if should[:metric]
    args += ['table', should[:table].to_s] if should[:table]
    args += ['scope', should[:scope].to_s] if should[:scope]
    args += ['proto', should[:proto].to_s] if should[:proto]
    args += ['src', should[:src]] if should[:src]
    args << 'onlink' if should[:onlink]
    args += ['type', should[:type].to_s] if should[:type]
    args
  end

  def create(context, _name, should)
    args = %w[route add]
    args += parse_route(should)
    route_exec(context, args)
  end

  def update(context, name, should)
    current = @current_state[name]
    if requires_replacement?(current, should)
      delete(context, name)
      create(context, name, should)
    else
      args = %w[route change]
      route_exec(context, args + parse_route(should))
    end
  end

  def delete(context, name)
    res = @current_state[name]
    unless res
      context.warning("Attempted to delete unknown route: #{name}")
      return
    end
    prefix = res[:prefix]
    table =  ['table', res[:table]] if res[:table] && res[:table] != 'main'
    args = ['route', 'del', prefix, table].compact
    route_exec(context, args)
  end

  def canonicalize(context, resources)
    resources.each do |res|
      if res[:prefix].nil?
        # If we haven't specified an explicit prefix, then try and see if the name is a valid CIDR or 'default'.
        # if it is, then move that to prefix.
        raise Puppet::Error, "Invalid prefix '#{res[:name]}'. Must be a valid CIDR or 'default'." unless res[:name] == 'default' || valid_cidr?(context, res[:name])

        res[:prefix] = res[:name]

      end
      # If Table is not specified, default to 'main'
      res[:table] ||= 'main'
      # ensure all metric values are integers
      res[:metric] = res[:metric].to_i if res[:metric]
    end
  end

  def valid_cidr?(context, value)
    # Accepts 'default' or CIDR like '10.0.0.0/24'
    return true if value == 'default'

    begin
      context.debug("Validating CIDR: #{value}")
      IPAddr.new(value)
    rescue IPAddr::InvalidPrefixError
      context.warning("Invalid CIDR prefix: #{value}. Must be a valid CIDR or 'default'.")
      return false
    rescue IPAddr::InvalidAddressError
      context.warning("Invalid CIDR format: #{value}. Must be a valid CIDR or 'default'.")
      return false
    end
    true
  end

  def requires_replacement?(is, should)
    %i[prefix table type proto scope].any? { |key| is[key] != should[key] }
  end

  def route_exec(context, *args)
    iproute_path ||= Puppet::Util.which('ip')
    final_cmd = [iproute_path, '-json'] + args.flatten
    context.debug("Executing command: #{final_cmd.join(' ')}")
    Puppet::Util::Execution.execute(final_cmd, failonfail: true)
  rescue Puppet::ExecutionFailure => e
    # Surface the error as Pupper::Error with a more descriptive message to make failures easier to debug
    raise Puppet::Error, "Command '#{args.join(' ')}' failed: #{e.message}"
  end
end
