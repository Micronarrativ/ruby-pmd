pdfmd/commands/config

# Description

Show the current used configuration.

# Usage

``` 
$ pdfmd config [command]
``` 

# Parameter

``` 
-l, --log <value>       Enable/Disable logging.
                        Default: true

``` 

# Example

``` 
# Show the whole configuration
$ pdfmd config 
---
default:
  loglevel: debug
show:
  format: yaml
  includepdf: true
...

# Show the configuration of the section 'default'
$ pdfmd config default
---
loglevel: default
$
``` 
