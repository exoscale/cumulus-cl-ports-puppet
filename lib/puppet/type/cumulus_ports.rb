Puppet::Type.newtype(:cumulus_ports) do
  @doc = "Configures initial port attributes on Cumulus Linux
  located in /etc/cumulus/ports.conf. it is important to define
  the entire port range with this version. That is if the switch is
  32 ports, make sure to define the port speed attributes for all 32
  ports. In a future version will be able to list only the interfaces
  you wish to change, and the rest will use the default setting.
  "

  newproperty(:ensure) do
    desc 'Reflects state of ports.conf config. if "insync" do nothing'

    # default setting set to what it "should" be, which is
    # in sync.
    defaultto :insync

    # retrieve function gets the current state of ports.conf
    # if ports.conf as defined by user is different than what
    # is configured, then change state of this property to
    # :outofsync
    def retrieve
      prov = @resource.provider
      if prov && prov.respond_to?(:config_changed?)
        result = @resource.provider.config_changed?
      else
        errormsg = 'unable to find a provider for cumulus_ports ' \
          'that has a "config_changed?" function'
        fail Puppet::DevError, errormsg
      end
      # retrieve function sets the property value. if property value
      # doesn't match defaultto setting, then it will execute code
      # under the newvalue :insync section, in an attempt to reach
      # desired state
      result ? :outofsync : :insync
    end

    newvalue :outofsync
    newvalue :insync do
      prov = @resource.provider
      if prov && prov.respond_to?(:update_config)
        prov.update_config
      else
        errormsg = 'unable to find a provider for cumulus_ports ' \
          ' that has a "update_config" function'
        fail Puppet::DevError, errormsg
      end
      nil
    end
  end

  newparam(:name) do
    desc 'used as the title for the module instantiation'
    # without it you get the error:
    # "No set of title patterns matched the title 'speeds'"
  end

  newparam(:speed_40g_div_4) do
    desc 'sets the port to a 40G/4 configuration'
  end

  newparam(:speed_4_by_10g) do
    desc 'sets the port to a 4x10G configuration'
  end

  newparam(:speed_4_by_25g) do
    desc 'sets the port to a 4x25G configuration'
  end

  newparam(:speed_2_by_50g) do
    desc 'sets the port to a 2x50G configuration'
  end

  newparam(:speed_10g) do
    desc 'sets the port to a 10G configuration'
  end

  newparam(:speed_40g) do
    desc 'sets the port to a 40G configuration'
  end

  newparam(:speed_50g) do
    desc 'sets the port to a 50G configuration'
  end

  newparam(:speed_100g) do
    desc 'sets the port to a 100G configuration'
  end
end
