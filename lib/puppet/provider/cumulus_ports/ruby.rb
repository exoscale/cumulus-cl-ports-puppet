require 'tempfile'

Puppet::Type.type(:cumulus_ports).provide :ruby do
  # If operating system is not cumulus
  # Puppet returns error:
  # "Could not find a suitable provider for cumulus_ports"
  # someone asked for a way to log why provider is not suitable
  # but unable to find progress on it. http://bit.ly/17Dhny6
  confine operatingsystem: [:cumulus_linux]

  def self.file_path
    '/etc/cumulus/ports.conf'
  end

  def expand_port_range(port_range_str)
    port_range_str.slice! 'swp'
    port_range = port_range_str.split('-')
    if port_range.length == 1
      return port_range
    else
      return(port_range[0]..port_range[1]).to_a
    end
  end

  # read current ports.conf config and return
  # port => port_attr config as a hash.
  def read_current_config
    current_port_hash = {}
    File.readlines(self.class.file_path).each do |line|
      # line starts with "<num>" followed by "="
      # e.g "10=40G" would match.
      # but "# 3=40G" would not
      if line.match('^\d+=')
        (portnum, portattr) = line.strip.split('=')
        current_port_hash[portnum.to_i] = portattr
      end
    end
    sort_hash(current_port_hash)
  end

  def self.portattrs
    {
      speed_10g: '10G',
      speed_40g: '40G',
      speed_4_by_10g: '4x10G',
      speed_40g_div_4: '40G/4'
    }
  end

  def get_list_of_ports(portlist)
    if portlist.class == String
      [portlist]
    else
      # do .to_a because variable may be nil which converts
      # it to a empty list :)
      portlist.to_a
    end
  end

  def add_to_desired_hash(list_of_ports, desired_port_hash, portattr_str)
    list_of_ports.each do |entry|
      port_range = expand_port_range(entry)
      port_range.each do |portnum|
        desired_port_hash[portnum.to_i] = portattr_str
      end
    end
  end

  def desired_config
    desired_port_hash = {}
    self.class.portattrs.each do |portattr, portattr_str|
      portlist = resource[portattr]
      list_of_ports = get_list_of_ports(portlist)
      add_to_desired_hash(list_of_ports, desired_port_hash, portattr_str)
    end
    sort_hash(desired_port_hash)
  end

  def sort_hash(myhash)
    myhash.sort_by do |portnum, _value|
      portnum
    end
  end

  def make_copy_of_orig
    file_path_copy = self.class.file_path + '.orig'
    return if File.exist(file_path_copy)
    Puppet.debug("make copy of origin #{self.class.file_path}")
    FileUtils.cp(self.class.file_path, file_path_copy)
  end

  def write_to_temp_file(temp_file)
    desired_port_hash = sort_hash(desired_config)
    temp_file.puts '#Managed by Puppet'
    temp_file.puts '#Original file can be found at ' \
      "#{self.class.file_path}.orig"
    desired_port_hash.each do |k, v|
      temp_file.puts k.to_s + '=' + v.to_s
    end
    temp_file.close
  end

  # Updates ports.conf config. Takes desired port config
  # writes it to a temp file, the moves it to the actual location
  # writing a temp file helps minimize file corruption when editing
  # the file.
  def update_config
    make_copy_of_orig
    temp_file = Tempfile.new('ports.conf')
    begin
      write_to_temp_file(temp_file)
      Puppet.debug("writing temp file to #{self.class.file_path}")
      FileUtils.mv(temp_file.path, self.class.file_path)
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

  # If current config and desired config don't match then
  # the config has changed . Func returns true
  def config_changed?
    current_conf = read_current_config
    desired_conf = desired_config
    current_conf != desired_conf
  end
end
