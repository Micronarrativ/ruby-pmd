pdfmd/command/sort

# Description

Show statistics about the metadata of the PDF documents in a directory.

# Usage

```
$ pdfmd stat [-r|--recursive] [-t|--tags <TAGS>] [-f|--format FORMAT]
             [-s|--status true|false] <directory>
```

# Parameter

```
-r, --recursive     If set to true, all documents from all subdirectories are
                    included.

                    Default: false

-f, --format        Sets alternative output formats.
                    The following formats are available:

                    * hash
                    * yaml
                    * json

                    Default: json

-s, --status        Enable/Disable the output during statistics calculations.

                    Default: true
```

# Examples

``` 
# Run statistics on the documents in the current directory.
$ pdfmd stat .

# Run statistics on the document and all subdirectories.
$ pdfmd stat -r .
``` 
