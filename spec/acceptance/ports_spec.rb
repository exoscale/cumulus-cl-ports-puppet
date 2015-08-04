require 'spec_helper_acceptance'

describe 'ports' do

  context 'valid ports definition' do

    it 'should work with no errors' do
      pp = <<-EOS
        # Create a fake ports.conf for VX
        file { '/etc/cumulus/ports.conf':
          content => "I am empty",
        }

        cumulus_ports { 'test':
          speed_40g_div_4 => ['swp1-4'],
          speed_10g => ['swp5-9'],
          speed_4_by_10g => ['swp10-14'],
          speed_40g => ['swp15-29'],
          require => File['/etc/cumulus/ports.conf'],
        }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/cumulus/ports.conf') do
      it { should exist }
    end

  end

end
