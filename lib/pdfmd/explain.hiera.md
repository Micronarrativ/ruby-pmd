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
      destination : /data/output
      copy        : true
      log         : true
      logfile     : /var/log/pdfmd.log
      interactive : true
    rename:
      allkeywords : true
      keywords    : 4
      outputdir   : /data/output/sorted
      copy        : true

