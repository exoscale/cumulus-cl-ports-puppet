require 'spec_helper'

cl_ports = Puppet::Type.type(:cumulus_ports)

describe cl_ports do
  let :params do
    [
        :name,
        :speed_40g,
        :speed_10g,
        :speed_40g_div_4,
        :speed_4_by_10g,
    ]
  end

  let :properties do
    [:ensure]
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

  context 'ensure property' do
    before do
      # call the ruby provider and assign it as the default provider
      # provider must be real. can't fake that.
      @provider = double 'provider'
      allow(@provider).to receive(:name).and_return(:ruby)
      cl_ports.stubs(:defaultprovider).returns @provider
      @cumulus_ports = cl_ports.new(:name => 'speeds')
    end
    subject { allow(@cumulus_ports.provider).to receive(:config_changed?) }
    let (:ensure_result) { @cumulus_ports.property(:ensure).retrieve }

    context "when provider config_changed? is false" do
      before do
        subject.and_return(false)
      end
      it { expect(ensure_result).to eq(:insync) }
    end

    context "when provider config_changed? is true" do
      before do
        subject.and_return(true)
      end
      it { expect(ensure_result).to eq(:outofsync) }
    end

    context 'insync provider call' do
      let(:provider) { @cumulus_ports.provider }
      let(:ensure_insync_exec) { @cumulus_ports.property(:ensure).set_insync }
      subject { ensure_insync_exec }
      it do
        expect(provider).to receive(:update_config).once
        subject
      end
    end
  end

end
