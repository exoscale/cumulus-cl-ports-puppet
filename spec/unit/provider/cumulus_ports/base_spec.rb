require 'spec_helper'
require 'pry'

provider_resource = Puppet::Type.type(:cumulus_ports)
provider_class = provider_resource.provider(:cumulus)

describe provider_class do
  before(:all) do
    # resource parameters require to be in arrays!!
    # wonder if I can get away from this requirement
    @resource = provider_resource.new(
      name: 'speeds',
      speed_4_by_10g: 'swp1-2',
      speed_40g: ['swp3'],
      speed_40g_div_4: %w(swp4 swp6),
      speed_10g: ['swp10']
    )
    @provider = provider_class.new(@resource)
  end

  context 'operating system confine' do
    subject do
      provider_class.confine_collection.summary[:variable][:operatingsystem]
    end
    it { is_expected.to eq ['cumuluslinux'] }
  end

  context 'ports.conf location' do
    subject { @provider.class.file_path }
    it { is_expected.to eq '/etc/cumulus/ports.conf' }
  end

  context 'expand range function' do
    subject { @provider.expand_port_range(port_range) }
    context 'when given an interface range' do
      let(:port_range) { 'swp1-3' }
      it { is_expected.to eq %w(1 2 3) }
    end
    context 'when given a single inteface' do
      let(:port_range) { 'swp10' }
      it { is_expected.to eq %w(10) }
    end
  end

  context 'read_current_config' do
    before do
      # stub File.readlines and have it return a ports.conf
      # file found in the spec directory
      filepath = File.dirname(__FILE__) + '/../../../files/ports.conf'
      ports_conf = File.readlines(filepath)
      allow(File).to receive(:readlines).and_return(ports_conf)
    end
    let(:curr_config) { @provider.read_current_config }
    context 'first entry' do
      subject { curr_config[0][1] }
      it { is_expected.to eq '40G' }
    end
    context 'tenth entry' do
      subject { curr_config[10][1] }
      it { is_expected.to eq '4x10G' }
    end
    context 'total number of interfaces' do
      subject { curr_config.length }
      it { is_expected.to eq 32 }
    end
  end

  context 'build_desired_config' do
    subject { @provider.build_desired_config }
    it do
      is_expected.to eq([[1, '4x10G'],
                         [2, '4x10G'],
                         [3, '40G'],
                         [4, '40G/4'],
                         [6, '40G/4'],
                         [10, '10G']])
    end
  end

  context 'update_config' do
    let(:tmpfile) { '/tmp/ports.conf' }
    let(:test_file) do
      File.dirname(__FILE__) + '/../../../files/ports.conf.generated'
    end
    before do
      allow(@provider).to receive(:make_copy_of_orig).once
      allow(@provider.class).to receive(:file_path).and_return(tmpfile)
      @provider.config_changed?
      @provider.update_config
    end
    it 'should create a proper ports.conf' do
      expect(File.readlines(tmpfile)).to eq File.readlines(test_file)
    end
  end

  context 'config_changed?' do
    context 'when actual config == desired config' do
      before do
        first_arr = [%w(1, '40G')], [%w(10,'4x10G')]
        allow(@provider).to receive(:read_current_config).and_return(first_arr)
        allow(@provider).to receive(:build_desired_config).and_return(first_arr)
      end
      subject { @provider.config_changed? }
      it { is_expected.to be false }
    end

    context 'when actual config != desired config' do
      before do
        first_arr = [%w(1 '40G')], [%w(10 '4x10')]
        sec_arr = [%w(2, '40G')]
        allow(@provider).to receive(:read_current_config).and_return(first_arr)
        allow(@provider).to receive(:build_desired_config).and_return(sec_arr)
      end
      subject { @provider.config_changed? }
      it { is_expected.to be true }
    end
  end
end
