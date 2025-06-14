require 'spec_helper'

module Puppet::Provider::Iproute; end
require 'puppet/provider/iproute/iproute'

describe Puppet::Provider::Iproute::Iproute do
  let(:provider) { described_class.new }
  let(:context) { instance_double('context', debug: nil) }

  describe '#get' do
    it 'returns an array of route hashes from route_exec' do
      # Random Assortment of routes to simulate the output of `route show table all`
      routes = [
        { 'dst' => 'default', 'gateway' => '172.26.176.1', 'dev' => 'eth0', 'protocol' => 'kernel', 'flags' => [] },
        { 'dst' => '172.17.0.0/16', 'dev' => 'docker0', 'protocol' => 'kernel', 'scopeq' => 'link', 'prefsrc' => '172.17.0.1', 'flags' => [] },
        { 'dst' => '172.26.176.0/20', 'dev' => 'eth0', 'protocol' => 'kernel', 'scope' => 'link', 'prefsrc' => '172.26.191.92', 'flags' => [] },
        { 'type' => 'local', 'dst' => '10.255.255.254', 'dev' => 'lo', 'table' => 'local', 'protocol' => 'kernel', 'scope' => 'host', 'prefsrc' => '10.255.255.254', 'flags' => [] },
        { 'type' => 'broadcast', 'dst' => '10.255.255.254', 'dev' => 'lo', 'table' => 'local', 'protocol' => 'kernel', 'scope' => 'link', 'prefsrc' => '10.255.255.254', 'flags' => [] },
        { 'type' => 'local', 'dst' => '127.0.0.0/8', 'dev' => 'lo', 'table' => 'local', 'protocol' => 'kernel', 'scope' => 'host', 'prefsrc' => '127.0.0.1', 'flags' => [] },
        { 'type' => 'local', 'dst' => '127.0.0.1', 'dev' => 'lo', 'table' => 'local', 'protocol' => 'kernel', 'scope' => 'host', 'prefsrc' => '127.0.0.1', 'flags' => [] },
        { 'type' => 'broadcast', 'dst' => '127.255.255.255', 'dev' => 'lo', 'table' => 'local', 'protocol' => 'kernel', 'scope' => 'link', 'prefsrc' => '127.0.0.1', 'flags' => [] },
        { 'type' => 'local', 'dst' => '172.17.0.1', 'dev' => 'docker0', 'table' => 'local', 'protocol' => 'kernel', 'scope' => 'host', 'prefsrc' => '172.17.0.1', 'flags' => [] },
        { 'type' => 'broadcast', 'dst' => '172.17.255.255', 'dev' => 'docker0', 'table' => 'local', 'protocol' => 'kernel', 'scope' => 'link', 'prefsrc' => '172.17.0.1', 'flags' => [] },
        { 'type' => 'local', 'dst' => '172.26.191.92', 'dev' => 'eth0', 'table' => 'local', 'protocol' => 'kernel', 'scope' => 'host', 'prefsrc' => '172.26.191.92', 'flags' => [] },
        { 'type' => 'broadcast', 'dst' => '172.26.191.255', 'dev' => 'eth0', 'table' => 'local', 'protocol' => 'kernel', 'scope' => 'link', 'prefsrc' => '172.26.191.92', 'flags' => [] },
        { 'dst' => 'fe80::/64', 'dev' => 'eth0', 'protocol' => 'kernel', 'metric' => 256, 'flags' => [], 'pref' => 'medium' },
        { 'dst' => 'fe80::/64', 'dev' => 'veth0518f99', 'protocol' => 'kernel', 'metric' => 256, 'flags' => [], 'pref' => 'medium' },
        { 'dst' => 'fe80::/64', 'dev' => 'docker0', 'protocol' => 'kernel', 'metric' => 256, 'flags' => [], 'pref' => 'medium' },
        { 'type' => 'local', 'dst' => '::1', 'dev' => 'lo', 'table' => 'local', 'protocol' => 'kernel', 'metric' => 0, 'flags' => [], 'pref' => 'medium' },
        { 'type' => 'local', 'dst' => 'fe80::215:5dff:fea7:3404', 'dev' => 'eth0', 'table' => 'local', 'protocol' => 'kernel', 'metric' => 0, 'flags' => [], 'pref' => 'medium' },
        { 'type' => 'local', 'dst' => 'fe80::9cad:42ff:fef8:6eea', 'dev' => 'veth0518f99', 'table' => 'local', 'protocol' => 'kernel', 'metric' => 0, 'flags' => [], 'pref' => 'medium' },
        { 'type' => 'local', 'dst' => 'fe80::d05d:39ff:fe25:2935', 'dev' => 'docker0', 'table' => 'local', 'protocol' => 'kernel', 'metric' => 0, 'flags' => [], 'pref' => 'medium' },
        { 'type' => 'multicast', 'dst' => 'ff00::/8', 'dev' => 'eth0', 'table' => 'local', 'protocol' => 'kernel', 'metric' => 256, 'flags' => [], 'pref' => 'medium' },
        { 'type' => 'multicast', 'dst' => 'ff00::/8', 'dev' => 'veth0518f99', 'table' => 'local', 'protocol' => 'kernel', 'metric' => 256, 'flags' => [], 'pref' => 'medium' },
        { 'type' => 'multicast', 'dst' => 'ff00::/8', 'dev' => 'docker0', 'table' => 'local', 'protocol' => 'kernel', 'metric' => 256, 'flags' => [], 'pref' => 'medium' }
      ]
      allow(provider).to receive(:route_exec).with(context, %w[route show table all]).and_return(routes)
      # { 'metric' => 256, 'flags' => [], 'pref' => 'medium' }
      result = provider.get(context)
      expect(result.first[:prefix]).to eq('default')
      expect(result.first[:table]).to eq('main')
      expect(result.first[:via]).to eq('172.26.176.1')
      expect(result.first[:dev]).to eq('eth0')
      expect(result.first[:proto]).to eq('kernel')
      # Last Entry
      expect(result.last[:prefix]).to eq('ff00::/8')
      expect(result.last[:dev]).to eq('docker0')
      expect(result.last[:table]).to eq('local')
      expect(result.last[:proto]).to eq('kernel')
      expect(result.last[:type]).to eq('multicast')
      expect(result.last[:metric]).to eq(256)
      expect(result.last[:scope]).to be_nil
      expect(result.last[:src]).to be_nil
      expect(result.last[:onlink]).to be(false)
    end
  end

  describe '#parse_route' do
    it 'returns an array of arguments for ip route' do
      should = {
        prefix: '10.0.0.0/24',
        via: '10.0.0.1',
        dev: 'eth0',
        metric: 100,
        table: 'main',
        scope: 'universe',
        proto: 'static',
        src: '10.0.0.2',
        onlink: true,
        type: 'unicast'
      }
      args = provider.parse_route(should)
      expect(args).to include('10.0.0.0/24', 'via', '10.0.0.1', 'dev', 'eth0', 'metric', '100', 'table', 'main', 'scope', 'universe', 'proto', 'static', 'src', '10.0.0.2', 'onlink', 'type', 'unicast')
    end
  end

  describe '#create' do
    it 'calls route_exec with add and parsed args' do
      should = { prefix: 'default', via: '192.168.1.1', table: 'main' }
      allow(provider).to receive(:parse_route).with(should).and_return(['default', 'via', '192.168.1.1', 'table', 'main'])
      allow(provider).to receive(:route_exec).with(context, ['route', 'add', 'default', 'via', '192.168.1.1', 'table', 'main'])
      provider.create(context, 'foo', should)
      expect(provider).to have_received(:route_exec).with(context, ['route', 'add', 'default', 'via', '192.168.1.1', 'table', 'main'])
    end
  end

  describe '#update' do
    it 'calls delete and create if replacement is required' do
      should = { prefix: '10.0.0.0/24', via: '192.168.0.2' }
      provider.instance_variable_set(:@current_state, { '10.0.0.0/24' => { prefix: '10.0.0.0/24', via: '192.168.0.1' } })
      allow(provider).to receive(:requires_replacement?).and_return(true)
      allow(provider).to receive(:delete).once
      allow(provider).to receive(:create).once
      allow(Puppet::Util::Execution).to receive(:execute).and_return(true)
      provider.update(context, '10.0.0.0/24', should)
      expect(provider).to have_received(:delete).with(context, '10.0.0.0/24')
      expect(provider).to have_received(:create).with(context, '10.0.0.0/24', should)
    end

    it 'calls route_exec with change if no replacement is required' do
      should = { prefix: '10.0.0.0/24', via: '192.168.0.3', dev: 'eth0'  }
      provider.instance_variable_set(:@current_state, { '10.0.0.0/24' => { prefix: '10.0.0.0/24', via: '192.168.0.1', dev: 'eth1' } })
      allow(provider).to receive(:requires_replacement?).and_return(false)
      allow(provider).to receive(:route_exec).with(context, %w[route change 10.0.0.0/24 via 192.168.0.3 dev eth0])
      provider.update(context, '10.0.0.0/24', should)
      expect(provider).to have_received(:route_exec).with(context, %w[route change 10.0.0.0/24 via 192.168.0.3 dev eth0])
    end
  end

  describe '#delete' do
    it 'calls route_exec with del and table option' do
      provider.instance_variable_set(:@current_state, { '10.0.0.0/24' => { prefix: '10.0.0.0/24', via: '192.168.0.1', table: 'main' } })
      allow(provider).to receive(:route_exec).with(context, ['route', 'del', '10.0.0.0/24'])
      provider.delete(context, '10.0.0.0/24')
      expect(provider).to have_received(:route_exec).with(context, %w[route del 10.0.0.0/24])
    end
  end

  describe '#canonicalize' do
    it 'sets prefix from name if missing and valid' do
      resources = [{ name: '10.0.0.0/24' }]
      allow(provider).to receive(:valid_cidr?).and_return(true)
      provider.canonicalize(context, resources)
      expect(resources.first[:prefix]).to eq('10.0.0.0/24')
    end

    it 'raises error for invalid prefix' do
      resources = [{ name: 'not_a_cidr' }]
      allow(provider).to receive(:valid_cidr?).and_return(false)
      expect { provider.canonicalize(context, resources) }.to raise_error(Puppet::Error)
    end

    it 'defaults table to main' do
      resources = [{ name: '10.0.0.0/24' }]
      allow(provider).to receive(:valid_cidr?).and_return(true)
      provider.canonicalize(context, resources)
      expect(resources.first[:table]).to eq('main')
    end

    it 'converts metric to integer' do
      resources = [{ name: '10.0.0.0/24', metric: '100' }]
      allow(provider).to receive(:valid_cidr?).and_return(true)
      provider.canonicalize(context, resources)
      expect(resources.first[:metric]).to eq(100)
    end
  end

  describe '#valid_cidr?' do
    it 'returns true for default' do
      allow(context).to receive(:warning).and_return('')
      expect(provider.valid_cidr?(context, 'default')).to be true
    end

    it 'returns true for valid CIDR' do
      allow(context).to receive(:warning).and_return('')
      expect(provider.valid_cidr?(context, '10.0.0.0/24')).to be true
    end

    it 'returns false for invalid CIDR' do
      allow(context).to receive(:warning).and_return('')
      expect(provider.valid_cidr?(context, 'invalid')).to be false
    end
  end
end
