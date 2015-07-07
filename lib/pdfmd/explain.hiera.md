Information about hiera: https://docs.puppetlabs.com/hiera/1/index.html

Installation:

```
$ gem install hiera
```

This is a list of all available hiera settings.

Configure default settings for pdfmd in hiera:


  YAML
  ---
  pdfmd::config:
    default:
      password    : secretpassword
      loglevel    : info|warn|error|debug
    sort:
      copy        : true
      destination : /data/output
      interactive : true
      log         : true
      logfile     : /var/log/pdfmd.log
    rename:
      allkeywords : true
      copy        : true
      defaultdoctype: doc
      keywords    : 4
      outputdir   : /data/output/sorted
      log         : true
      logfile     : /var/log/pdfmd.log
    rename:
      allkeywords : true
      copy        : true
      defaultdoctype: doc
      keywords    : 4
      outputdir   : /data/output/sorted
      log         : true
      logfile     : /var/log/pdfmd.log
    rename:
      allkeywords : true
      copy        : true
      defaultdoctype: doc
      keywords    : 4
      outputdir   : /data/output/sorted
    edit:
      rename      : true
      opendoc     : true
      pdfviewer   : evince
      log         : true
      logfile     : /var/log/pdfmd.log
