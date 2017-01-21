pdfmd/commands/sort

# Description

This command will sort pdf documents into subdirectories. The destination directories are fetched from the metatadata in the document, slightly adjusted if necessary.

If a file does not have a value for the metatag *author*, the file will not be processed.

# Usage

```
$ pdfmd sort [-d|--destination <path>] [-c|--copy [true|false]]
             [-i|--interactive [true|false]] [-o|--overwrite [true|false]]
             [-n|--dry-run [true|false]] [-t|--typo [true|false]]
```

# Parameter

```
-d, --destination   Specify the root output directory to where the folder
                    structure is being created.
                    This parameter is required on the commandline if Hiera
                    does not provide a value for it.

                    The command line parameter will overwrite any existing
                    Hiera setting.

                    Default: current working directory

                    Hiera key: pdfmd::config => sort => destination 

-n, --dryrun        If set to true, this parameter will performa all actions as
                    usual, but there will no actual sorting or changes of any
                    kind.

                    Default: false

                    Hiera key: pdfmd::config => sort => dryryn

-n, --dryrun        If set to true, this parameter will performa all actions as
                    usual, but there will no actual sorting or changes of any
                    kind.

                    Default: false

                    Hiera key: pdfmd::config => sort => dryryn

-c, --copy          Copy the file instead of moving it.

                    Default: false

                    Hiera key: pdfmd::config => sort => copy

-l, --log           Disable/Enable the logging.

                    Default: true

-p, --logfile       Set an alternative path for the logfile. If no path is
                    chosen, the logfile gets created in the current working
                    directory as `.pdfmd.log`.

-i, --interactive   Disable/Enable interactive sorting. Setting this parameter
                    will ask for configuration for each sorting action.

                    Default: false

-o, --overwrite     If set to true, this parameter will overwrite any existing
                    file at the target destination with the same name without
                    asking.

                    Default: false

-t, --typo          If set subdirectories with similar spelling will be
                    reported before a new folder is being created. Similar
                    directory wording can be caused by typos in the author
                    field in the metatadata of the document.
```

# Hiera
## General

Parameter can be set in Hiera as default. Those will be reused unless overwritten on the commandline.

``` 
pdfmd::config:
  sort:
    destination:
    dest_create: true|false
    interactive: true|false
    copy: true|false
    typo: true|false
```

## Additional parameter

``` 
dest_create   If this key is set to true, the destination directory will be
              created if it is missing.

              Default: false
```
# Rules

The subdirectories for the pdf documents are generated from the values in the tag *author* of each document. In order to ensure a clean directory structure, there are certain rules for altering the values.

1. Whitespaces are replaced by underscores ('\_').
2. Dots are replaced with underscores.
3. All characters are changed to their lowercase version.
4. Special characters are serialized.

# Examples

``` 
# Copy all documents in the subdirectory ./documents, create a folder
# structure in `/tmp/test`, copy the files instead of moving them and disable
# logging.
$ pdfmd sort -d /tmp/test -c -l false ./documents

# Sort a single file with the same other options as in the previous example.
$ pdfmd sort -d /tmp/test -c -l -false ./documents/test.pdf
```

# Typos

The parameter *--typo* may cause *pdfmd* to show a warning during the sorting process. *Pdfmd* will check if there is an destination directory for the document already created, which has a similar bt-in
