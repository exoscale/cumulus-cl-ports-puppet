require 'spec_helper'

describe 'cumulus_ports::speeds' do
  describe 'using cumulus' do
    let(:facts) { { :operatingsystem => 'CumulusLinux' } }
    let(:title) { 'speeds' }
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
end
