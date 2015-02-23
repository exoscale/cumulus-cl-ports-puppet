require 'spec_helper'

cl_ports = Puppet::Type.type(:cumulus_ports)

describe cl_ports do
  let :params do
    [
        :name,
        :speed_40g,
        :speed_10g,
        :speed_40g_div_4,
        :speed_4_by_10g
    ]
  end

  let :properties do
    [
      :ensure
    ]
  end

  it 'should have expected properties' do
    properties.each do |property|
      expect(cl_ports.properties.map(&:name)).to be_include(property)
    end
  end

  it 'should have expected parameters' do
    params.each do |param|
      expect(cl_ports.parameters).to be_include(param)
    end
  end
end
