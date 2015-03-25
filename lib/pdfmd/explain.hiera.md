Information about hiera: https://docs.puppetlabs.com/hiera/1/index.html

Installation:

``` 
$ gem install hiera
```

Configure default settings in hiera:

  YAML
  ---
  pdfmd::config:
    sort:
      destination : /tmp/output
      copy        : true
      logfile     : /var/log/pdfmd.log

