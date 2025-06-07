require 'spec_helper'
require 'puppet/type/iproute'

RSpec.describe Puppet::Type.type(:iproute) do
  it 'loads' do
    expect(Puppet::Type.type(:iproute)).not_to be_nil
  end
  it 'has a namevar for prefix' do
    expect(Puppet::Type.type(:iproute).key_attributes).to eq([:prefix, :table])
  end
  it 'has an ensure attribute' do
    expect(Puppet::Type.type(:iproute).attrclass(:ensure)).not_to be_nil
  end
  it 'has a prefix attribute' do
    expect(Puppet::Type.type(:iproute).attrclass(:prefix)).not_to be_nil
  end
end
