module Puppet::Parser::Functions
  newfunction(:ports_conf, :type => :rvalue) do |args|
    speed_type_hash = args[0]
    port_config = PortConf.new()
    speed_type_hash.each do |speed_type_name, list_of_ports|
      port_config.add_to_hash(speed_type_name, list_of_ports)
    end
    port_config.sort_hash()
    port_config.port_hash
  end
end

class PortConf
  attr_accessor :port_hash
  def initialize
    @port_hash = {}
  end

  def sort_hash
    @port_hash = @port_hash.sort_by { |port_num, value| port_num}
  end

  def add_to_hash(speed_type_name, list_of_ports)
    list_of_ports.each do |entry|
      port_range = get_range(entry)
      port_range.each do |port_num|
        @port_hash[port_num.to_i] = speed_type_name
      end
    end
  end

  def get_range(port_range_str)
    port_range_str.slice! 'swp'
    port_range = port_range_str.split('-')
    if port_range.length == 1
      return port_range
    else
      return(port_range[0]..port_range[1]).to_a
    end
  end
end
