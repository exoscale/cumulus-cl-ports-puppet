require 'spec_helper_acceptance'

describe 'ports' do
  context 'valid ports definition' do
    it 'should work with no errors' do
      pp = <<-EOS
        # Create a fake ports.conf for VX
        file { '/etc/cumulus/ports.conf':
          content => "I am empty",
        }

        cumulus_ports { 'speeds':
          speed_10g       => ['swp1'],
          speed_40g       => ['swp3','swp5-10', 'swp12'],
          speed_40g_div_4 => ['swp15','swp16'],
          speed_4_by_10g  => ['swp20-32'],
          require         => File['/etc/cumulus/ports.conf'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/cumulus') do
      it { should be_directory }
    end

    describe file('/etc/cumulus/ports.conf') do
      it { should be_file }
      its(:content) { should match(/#Managed by Puppet/) }
      its(:content) { should match(/1=10G/) }
      its(:content) { should match(/3=40G/) }
      its(:content) { should match(/5=40G/) }
      its(:content) { should match(/10=40G/) }
      its(:content) { should match(/12=40G/) }
      its(:content) { should match(%r{15=40G/4}) }
      its(:content) { should match(%r{16=40G/4}) }
      its(:content) { should match(/20=4x10G/) }
      its(:content) { should match(/32=4x10G/) }
    end
  end
end
