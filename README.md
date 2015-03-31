# cumulus_ports for Puppet

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What cumulus_ports affects](#what-cumulus_ports-affects)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module configures the switch port attributes defined in `/etc/cumulus/ports.conf`

## Module Description

The `cumulus_ports` module  is responsible for setting the initial speed of 10G or 40G port. On some bare metal switches, it is possible to take a 40G port and split it up into four 10G ports using a breakout cable. For more details, visit [Cumulus Linux User Guide](http://docs.cumulusnetworks.com) and search for "Switch Port Attributes"

## Setup

### What cumulus_ports affects

This module affects the `/etc/cumulus/ports.conf` file
To activate the changes in the file, the `switchd` daemon must be restarted using `service switchd restart`

**NOTE**: 
restarting the `switchd` daemon is disruptive


## Usage

Configure `swp5` through `swp48` as 10GbE ports, `swp49` & `swp51` through `swp52` as 40GbE ports, `swp1` through `swp4` as 4 x 10GbE ports and `swp50` as 1 x 40GbE aggregate ports.

```
node default {
	cumulus_ports { 'speeds':
		speed_10g  => ['swp5-48'],
		speed_40g => ['swp49','swp51-52'],
		speed_40g_div_4 => ['swp1-4'],
		speed_4_by_10g => ['swp50'],
	    notify => Service['switchd']
	}
}

```

## Reference

**Parameters:**

`speed_10g` - Array of ports to be configured for 10GbE.
`speed_40g` - Array of ports to be configured for 40GbE.
`speed_40_div_4` - Array of ports to be configured for 40GbE split to 4 x 10GbE.
`speed_4_by_10g` - Array of ports to be configured for 10GbE to be aggregated into 1 x 40GbE.


## Limitations

This module only works on Cumulus Linux.

The module, currently, does not do any error checking. Ensure all config is thoroughly tested or the switch can behave in unpredictable ways.

`puppet resource cumulus_ports` is currently not implemented in this release. It may be added in a future release.

## Development

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create new Pull Request.


![Cumulus icon](http://cumulusnetworks.com/static/cumulus/img/logo_2014.png)

### Cumulus Linux

Cumulus Linux is a software distribution that runs on top of industry standard networking hardware. It enables the latest Linux applications and automation tools on networking gear while delivering new levels of innovation and ﬂexibility to the data center.

For further details please see: [cumulusnetworks.com](http://www.cumulusnetworks.com)

## CONTRIBUTORS

- Stanley Karunditu [@skamithi](https://github.com/skamithi)
