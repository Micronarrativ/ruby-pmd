pdfmd/hiera

# Description

Hiera is s simple pluggable Hierarchical Database. Multiple backends are supported, the default backend are files in the yaml format. It can be used for all kinds of data.

Since it is so simple to implement and to edit, Hiera is supported by pdfmd.

By replicating the database of *hiera* to other systems and restructuring the configuration depending on the host it runs on, *pdfmd* can be configured to behave differently on differen hosts.

# Installation

From the doc:

> Hiera is available as a Gem called _hiera_ and out of the box it comes with just a single
> YAML backend.
> 
> Hiera is also available as a native package via apt ([http://apt.puppetlabs.com](http://apt-puppetlabs.com)) and yum ([http://yum.puppetlabs.com](http://yum.puppetlabs.com)). Instructions for adding these repositories can be found at [http://docs.puppetlabs.com/guides/installation.html#debian-and-ubuntu](http://docs.puppetlabs.com/guides/installation.html#debian-and-ubuntu) and [http://docs.puppetlabs.com/guides/installation.html#enterprise-linux](http://docs.puppetlabs.com/guides/installation.html#enterprise-linux) respectively.
> 
> At present JSON ([github/ripienaar/hiera-json](github/ripienaar/hiera-json)) and Puppet (hiera-puppet) backends are availble.


# Configuration

``` 
---
:backends:
  - yaml

:hierarchy:
  - defaults

:yaml:
  :datadir: /path/to/hieradata
``` 

* This configuration will required yaml files in `/path/to/hieradata`. Only a datafile called `defaults.yaml` is defined in the backend. This file needs to contain hash data.
* The file `defaults.yaml` needs to be structured like the following example:

``` 
---
pdfmd::config:
  default:
    loglevel: debug
  show:
    format: yaml
    includepdf: true
  edit:
    rename: true
    opendoc: true
    pdfviewer: mupdf
  rename:
    keys:
      inv: Invoice
      ord: ['Order', 'Ordernumber']
      con: Contract
``` 

# Usage 
## Commandline

* Configured correctly the pdfmd configuration can be queried directly from the commandline using *hiera*:

``` 
$ hiera pdfmd::config
{"default"=>{"loglevel"=>"debug"},
 "show"=>{"format"=>"yaml", "includepdf"=>true},
 "edit"=>
  {"rename"=>true,
   "opendoc"=>true,
   "pdfviewer"=>"mupdf"},
 "rename"=>
   "keys" =>
    {"inv"=>'Invoice',
     "ord"=>['Order', 'Ordernumber'],},
   ....
```

or with `pdfmd config`

```
$ pdfmd config
---
default:
  loglevel: debug
show:
  format: yaml
  includepdf: true
edit:
  rename: true
  opendoc: true
  pdfviewer: mupdf
rename:
  keys:
    inv: Invoice
    ord: 
      - Order
      - Ordernumber
```

## Pdfmd config

The parameter *config* shows the whole configuration from *hiera* or a subsection that can be defined by adding the section to the comand.

```
$ pdfmd config show
---
format: yaml
includepdf: true
```
