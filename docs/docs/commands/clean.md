pdfmd/commands/clean

# Description

Remove all metatags that `pdfmd` handles from the document or a number of documents.  
The tag in the metatadata is not being removed, but the value is set to an empty value instead.

# Usage

``` 
$ pdfmd clean <pdf-file>
``` 

# Parameter

``` 
-t, --tags=TAGS       Comma separated list of tags.
                      The keyword *all* marks all tags used by pdfmd.
``` 

# Example

``` 
$ pdfmd clean -t author,title example.pdf
$
``` 
