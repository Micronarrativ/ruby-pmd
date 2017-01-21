pdfmd/commands/rename

# Description

Rename a file according to the meta tags of the document.

# Usage

```
$ pdfmd rename [-a|--allkeywords] [-c|--copy [true]] [-k|--nrkeywords <integer>]
                [-l, --log [true]] [-n|--dry-run [true]]
                [-o|--outputdir <directoryPath>] [-p|--logfile <logfilePath>]

```

# Parameter

```
-a, --allkeywords   Use all keywords from the meta tags within the file name.
                    This will ignore the the limit for keywords to use in a
                    filename.
                    Default: false

                    Hiera {pdfmd::config => { rename => { allkeywords => true }}}
                   

-c, --copy          Copy the file instead of moving the file to the new destination.
                    Default: false

-k, --nrkeywords    If set to integer, this parameter will limit the number of 
                    keywords used in the filename.
                    Default: 3

-l, --log           Enable or disable logging.
                    Default: true

                    Hiera { pdfmd::config => { rename => { log => true } } }

-n, --dry-run       If set to true, this will simulate the renaming of the file
                    without changing the file.
                    Default: true

-o, --outputdir     If set to an existing path, the renamed file will be moved there (unless `-c` has been specified).
                    Otherwise the the location of the file will not be changed.

-p, --logfile       If set to an existing path, the output file will be written to that location.
                    Defaults to the current working directory.
```

# Hiera

## General

```
# YAML
---
pdfmd::config:
  rename:
    dryrun         : true|false
    defaultdoctype : doc
    allkeywords    : true|false
    outputdir      : /tmp
    nrkeywords     : 3
    copy           : true|false
    log            : true|false
    logfile        : /var/log/pdfmd.log

```

## defaultdoctype

Sets the default abbreviation for documents, that cannot be matched. This is used when no other document type could be determined from the metadata field `title`.

This settings is not available as command line parameter.

Default: doc

# Examples

## General

``` 
# Rename the file according to the metatags
$ pdfmd rename <inputfile>

# Rename `example.pdf` according to the metatags
$ pdfmd rename example.pdf

# Simulate renaming `example.pdf` according to the metatags
$ pdfmd rename -n example.pdf
``` 

## Detailed

* A file `example.pdf` with the following meta tags being set:

``` 
Filename   : example.pdf
Author     : John
Title      : Presentation
Subject    : New Product
CreateDate : 1970:01:01 01:00:00
Keywords   : John Doe, Jane Doe, Mister Doe
``` 

``` 
# Renaming the file
$ pdfmd rename example.pdf
New filename: 19700101-john-dok-new_product-john_doe-jane_doe.pdf

# Simulation to rename te file (no actual change)
$ pdfmd rename -n example.pdf
New filename: example.pdf

# Renaming the file with all keywords
$ pdfmd rename -a example.pdf
New filename: 19700101-john-dok-new_product-john_doe-jane_doe-mister_doe.pdf
``` 

# Rules

There are some rules regarding how documents are being renamed.

## Rule 1

### Basic

All documents have the following filenaming structure:

``` 
<YYYYmmdd>-<author>-<documenttype>-<topics>.<extension>

  YYYY         : Year in a 4 digit number
  mm           : Month in a two digit number with leading zero
  dd           : Day in a two digit number with leading zero
  author       : Value from the metatag 'author', without spaces, in lowercase
                 and replaced special characters.
  documenttype : Abbreviation for document type. Defaults to 'doc', unless
                 otherwise specified or overwritten. See the details above
                 the documenttype below for details.
  topics       : Additional information generated from the tags 'title',
                 'subject' and 'keywords'. 
  extension    : The file extension.
``` 

### Document type

The document type is being determined from the metatag field *title*. The document type is supposed to be a three character abbreviation, depending on the type of document:

```
con: Contract
doc: General document
inv: Invoice
inf: Information
man: Manual
off: Offer
ord: Order
rpt: Receipt
tic: Ticket
``` 

* If the document type cannot be identified by the metatag *title*, it defaults to *doc*, unless it has been overwritten by the parameter *documenttype* in Hiera or the command line.

* This default behavior got introduced with version 1.8.1 and can be overwritten by Hiera.

TODO: Add more information about this in hiera.

### Topics

The topics in the filename are automatically generated from the metatag fields

* title
* subject
* keywords

If the metatag fields 'title' and 'keywords' contain one of the words from listed in Document type, it will be replaced with the corresponding abbreviation, e.g.:

``` 
Contact     => con
Invoice     => inv
Information => inf
Manual      => man
...
```

* This can be overwritten by setting the keys parameter in Hiera.
* This will result in a shorter filename with a more predictable length.
  For example with the hiera key defining the customer number as well:

```
# Hiera
...
man: Manual
cnr: Customernumber
...


# Filename without replacement
19700101-author-invoice-99999999-customernumber_8888888-example_text.pdf

# Filename with replacement
19700101-author-inv-99999999-cnr8888888-example_text.pdf 

```
 
## Rule 2

The number of keywords used in the filename is defined by the parameter *-k* and defaults to 3. This means the first three keywords will be consideres in the filerenaming, the rest will not be considered.

## Rule 3

The following keywords are prioritised:

* kvi
* fak
* ord
* kdn

## Rule 4

Special character and whitespaces are replaced.

``` 
whitespace => '_'
/          => '_'
```

## Rule 5

The new filename has only lowercase characters.
