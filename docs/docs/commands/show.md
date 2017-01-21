pdfmd/commands/show

# Description

Show the managed metatags of a PDF document.

Managed tags are

* author
* createdate
* title
* subject
* keywords

# Usage

```
$ pdfmd show [-t|--tag <TAG>] [-f|--format <FORMAT>] [-i|--includepdf]
    [-p|--logfile <logfilepath>] [-i|--log <true|false>]
```

# Parameter

```
-t, --tag           Single or list of metatags to include in the output. The 
                    selected tag(s) must be one of the managed ones listed
                    above. Other tags are ignored.
                    Multiple tags can be specified, separated by commata.
                    If multiple tags are specified, the order in which the
                    tags are specified is being used for the output. This will
                    impact the order of fields, when exporting e.g. to CSV.
                    The tag is case insensitive: 'AuThor' == 'author'.

                    Hiera key: `pdfmd::config => show => tag`

-a, --all           Include all managed metatags in the output. This is the
                    default setting.

-f, --format        If set, this parameter can be used to alter the output
                    format.
                    Possible values are: 'json', 'yaml', 'csv' and 'hash'.
                    Default value is 'yaml'.

                    Hiera key: `pdfmd::config => show => format`

-i, --includepdf    If set to 'true', the output will also include the 
                    filename of the processed file.
                    Default: false

                    Hiera key: `pdfmd::config => show => includepdf`

-p, --logfile       Specifies the path to the logfile.
                    Defaults to: './.pdfmd.log'

                    Hiera key: `pdfmd::config => show => logfile`

-i, --log           Enables/Disablss logging.
                    Defaults to 'true'.

                    Hiera key: `pdfmd::config => show => log`
```

# Hiera

```
# YAML
---
pdfmd::config:
  show:
    format: yaml|json|csv|hash
    tag: author,subject,createdate,title,keywords
    includepdf: true|false
    log: true|false
    logfile: /var/log/pdfmd.log
```


# Examples

```
# Show default metatags for a pdf document
$ pdfmd show example.pdf

# Show values for the metatags 'author' for the file 'example.pdf'.
$ pdfmd show -t author example.pdf

# Show values for the metatags 'author', 'title', for the file 'example.pdf'.
$ pdfmd show -t author,title example.pdf
```
