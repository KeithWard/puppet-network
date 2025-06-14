# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/nm_connection'

RSpec.describe 'the nm_connection type' do
  it 'loads' do
    expect(Puppet::Type.type(:nm_connection)).not_to be_nil
  end
end
