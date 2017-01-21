pdfmd/commands/edit

# Description

The edit command will edit the tags in the metadata of a PDF document. Multiple values can be specified or *all*.

The command will invoke an interactive user input and request the values for the metatag, unless a value is defined as parameter value.

The edit command can be chained with the command *rename*. This will automatically rename the PDf document  according to the metadata tags. See the documentation for the command [rename](rename.md "rename") for details.

# Usage

```
$ pdfmd edit -t|--tag <TAG> [-r|--rename] [-o|--opendoc] <document[s]>
```

# Parameter

```
-l, --log           Enable/Disable the logging.dddd
                    Default: true

-o, --opendoc       If set to *true*, the application defined in *pdfviewer*
                    from Hiera will be used to open the document while
                    interactively asking for the new tags values.

                    See further informations about *pdfviewer* below.

-p, --logfilepath   Path to the logfile.
                    Default: ./.pdfmd.log

-t, --tag           Fieldname or list of fieldnames of the tags to update. In a
                    list of fieldnames single names must be separated by
                    commata.

                    If a value is provided, the current value will be replaced
                    by the provided value.

                    This parameter cannot be defined in Hiera and needs to be
                    specified on the command line (hence the interactivity).

-r, --rename        If set, the command will trigger the renaming command in
                    order to adjust the filename to the changes in the metadata.

                    Setting this parameter is identical to running the command:

                    $ pdfmd rename <filename>
```

# Hiera

```
# YAML
---
pdfmd::config:
  edit:
    rename    : true|false
    log       : true|false
    logfile   : /var/log/pdfmd.log
    opendoc   : true|false
    pdfviewer : <binary>
```

## opendoc

If set to true the command will try to start a the pdfviewer specified in *pdfviewer* and display the PDF document while editing. If all values are being specified to the tags (e.g.: `author='John Doe'`), the pdf viewer will not be started.

Only if some user interaction is requested.

The process of the viewer will be automatically killed when the editing of the document has been finished.

There is no equivalent command line parameter for setting the viewer binary.


## pdfviewer

Binary or path to the binary to run as PDF document viewer. The filepath of the PDF document will be provided to the binary as argument.

Default: evince

There is no corresponding commandline parameter to set the value. This is only available from Hiera.

# Example

## General

```
# Edit tag 'TAG' and set a new value interactive.
$ pdfmd edit -t TAG <filename>
...

# Edit tag 'Author' and set new value interactive.
$ pdfmd edit -t author example.pdf
...

# Edit multiple Tags and set a new value interactive.
$ pdfmd edit -t tag1,tag2,tag3 <filename>
...

# Edit multiple Tags and set a new value in batch mode.
$ pdfmd edit -t tag1='value1',tag2='value2' <filename>
```

## Multiple tags

For setting multiple tags list the tags comma separated.  
For setting all tags (Author, Title, Subject, CreateDate, Keywords) use the keyword 'all' as tagname.

```
# Set tags 'Author', 'Title', 'Subject' in example.pdf interactivly.
$ pdfmd edit -t author,title,subject example.pdf`

# Set tags 'Author', 'Title', 'Subject', 'CreateDate', 'Keywords' in example.pdf interactively:
$ pdfmd edit -t all example.pdf

# Set tags 'Author', 'CreateDate' in example.pdf in batch mode (non-interactive):
pdfmd edit -t author='Me',createdate='1970:00:00 01:01:01' example.pdf
pdfmd edit -t author='Me',Createdate=19700000 example.pdf
```

# Tags
## createdate

In order to set the value for the metadata field *createdate*, the standard format 'YYYY-mm-dd HH:MM:SS' is accepted.

To allow easier input of values, internal matching will try to interpret the input value.

The following formats will be accepted:

```
yyyymmdd
yyyymmd
yyyymmddHHMMSS
yyyy-mm-dd HH:MM:SS
yyyy:mm:dd HH:MM:SS
yyyy.mm.dd HH:MM:SS
yyyy-mm-d
yyyy-mm-dd
yyyy.mm.d
yyyy.mm.dd
yyyy:mm:d
yyyy:mm:dd
```

- If no time (HH:MM:SS or HHMMSS) is provided, those values are automatically set to zero.
- The output format of every timestamp is <YYYY-mm-dd HH:MM:SS>
- When providing and invalid date, the incorrect date is rejected and the user asked to provide the correct date.
- When no date is provided, the current date value is used. It is not possible to empty the date value field.


# Rename file

In addition to setting the tags the current file can be renamed according to
the new metadata.

```
# Set tag 'Author' and rename file example.pdf
$ pdfmd edit -t author -r example.pdf
```

```
# Hiera
---
pdfmd::config:
  edit:
    rename: true
```

* See `pdfmd help rename` for details about renaming.
* To enable this feature in hiera add the key *rename* into the section *edit* with the value *true*.

# Passwords

*Pdfmd* will try to figure out if a document is protected by a password. If a password is required, the processing will stop and the user been asked to provide a password.

A default password can also be specified via [Hiera](/hiera "Hiera").

This will set the password in [Hiera](/hiera "Hiera") to 'secret': 

```
---
pdfmd::config:
  default:
    password: secret
```

The password request to the user is triggered only when no password has been found in [Hiera](/hiera "Hiera").
