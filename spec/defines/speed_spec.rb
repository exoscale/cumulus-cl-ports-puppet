require 'spec_helper'

describe 'cumulus_ports::speeds' do
  let(:title) { 'speeds' }
  let(:facts) { { :operatingsystem => 'CumulusLinux' }}
  describe 'using cumulus' do
    it { should contain_file('/etc/cumulus/ports.conf') }
  end
  describe 'not using cumulus' do
    let(:error_msg) { 'cumulus_ports module is not supported' +
      ' by Ubuntu based systems' }
    let(:facts) { { :operatingsystem => 'Ubuntu' } }
    let(:title) { 'speeds' }
    it do
      expect {
        should contain_file('/etc/cumulus/ports.conf')
      }.to raise_error(
        Puppet::Error, %r{#{error_msg}})
    end
  end
  describe "test proper formating of " do
    describe "10G format" do
      let(:params) { {:speed_10g => 'swp1'}}
      it { should contain_file('/etc/cumulus/ports.conf') \
        .with_content(%r{1=10G}) }
    end
    describe "40G format" do
      let(:params) { {:speed_40g => 'swp1'}}
      it { should contain_file('/etc/cumulus/ports.conf') \
        .with_content(%r{1=40G}) }
    end
    describe "10x4 format" do
      let(:params) { {:speed_10g_by_4 => 'swp1'}}
      it { should contain_file('/etc/cumulus/ports.conf') \
        .with_content(%r{1=4x10G}) }
    end
    describe "40/4 format" do
      let(:params) { {:speed_40g_div_4 => 'swp1'}}
      it { should contain_file('/etc/cumulus/ports.conf') \
        .with_content(%r{1=40G/4}) }
    end
  end
end
