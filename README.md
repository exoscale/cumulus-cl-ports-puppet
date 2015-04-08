# cumulus_ports for Puppet

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What cumulus_ports affects](#what-cumulus_ports  -affects)
    * [Beginning with cumulus_ports](#beginning-with-cumulus_ports)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This Puppet module provides a simple interface for managing initial port configuration
on Cumulus Linux.

## Module Description

The ``cumulus_ports`` module is responsible for setting the initial speed of a 10G or
40G port. On some bare metal switches, it is possible to take a 40G port and split it up
into four 10G ports using a breakout cable. For more details, read the [Cumulus
Linux User Guide](http://docs.cumulusnetworks.com) and search for
"Switch Port Attributes".

## Setup

### What cumulus_ports affects

* This module affects the `/etc/cumulus/ports.conf` file.
* To activate the changes in the file, the `switchd` daemon must be restarted.

> **NOTE**: Restarting the `switchd` daemon is disruptive.


### Beginning with cumulus_ports

This module does not use any default parameters. Support for default parameters is on the roadmap.

## Usage

The module currently supports one define, `cumulus_ports::speeds`:

```
node default {
  cumulus_ports { 'speeds':
    speed_40g_div_4 => ["swp1-4"],
    speed_10g => ["swp5-48"],
    speed_4_by_10g => ["swp49-50"],
    speed_40g => ["swp51-52"]
  }
}

```

## Reference

###Types

####`cumulus_ports`

Generates a custom `/etc/cumulus/ports.conf` based on the following variables:

* `speed_10g`: `speed_10g => 'swp1-2'` produces the following text in `/etc/cumulus/ports.conf`:

  ```
  swp1=10G
  swp2=10G
  ```

* `speed_40g` : `speed_40g => 'swp1-2'` produces the following text in `/etc/cumulus/ports.conf`:

  ```
  swp1=40G
  swp2=40G
  ```

* `speed_40g_div_4`: `speed_40g_div_4 => ['swp1', 'swp4']` produces the following text in `/etc/cumulus/ports.conf`:

  ```
  swp1=40/4
  swp4=40/4
  ```

* `speed_4_by_10g`: `speed_4_by_10g => 'swp1-2'` produces the following text in `/etc/cumulus/ports.conf`:

  ```
  swp1=4x10G
  swp2=4x10G
  ```

## Limitations

This module only works on Cumulus Linux.

The module does not currently do any error checking. Ensure that the whole configuration is thoroughly tested, or the switch can
behave in unpredictable ways.

`puppet resource cumulus_ports` doesn't currently work. This will be implemented in a later version.

## Development

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create new Pull Request.

## Cumulus Linux

![Cumulus icon](http://cumulusnetworks.com/static/cumulus/img/logo_2014.png)

Cumulus Linux is a software distribution that runs on top of industry-standard
networking hardware. It enables the latest Linux applications and automation
tools on networking gear while delivering new levels of innovation and
ﬂexibility to the data center.

For further details please see [cumulusnetworks.com](http://www.cumulusnetworks.com).
