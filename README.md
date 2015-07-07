# pdfmd
Pdf Meta data managing script.

I use the script `pdfmd.rb`/pdfmetadata (with a slightly different name) to manage my PDF documents and keep the naming in line.  
Hidden deep in the directory structure of my disks I can quickly find the
documents I need with a quick `find /document/path -type f -iname
'*<keyword>*'` which matches some string in the filename.

# Requirements

Although the requirements are listed in the script itself as well (header documentation!), here they are again:

## Ruby Gems

1. [thor](https://rubygems.org/gems/thor)
2. [highline/import](https://rubygems.org/gems/highline)
3. [fileutils](https://rubygems.org/gems/fileutils)
4. [i18n](https://rubygems.org/gems/i18n)
5. [logger]()
6. [pathname]()

Install the requirements as usual

```
$ gem install thor
$ gem install highline
$ gem install fileutils
$ gem install i18n
$ gem install pathname
$ gem install logger
```

## Platforms
### Fedora 21/CentOS 7
* Install the depencies (required to install the rmagick gem)

```
$ sudo yum install -y rubygems rubygems-devel gcc ImageMagick ruby-devel ImageMagick-devel
```

* Install Gem

``` 
$ gem install pdfmd
```

### Ubuntu 14.04 LTS

* Install the dependencies

```
$ sudo apt-get install -y rubygems-integration imagemagick libmagickwand-dev ruby-dev
``` 

* Install gem

``` 
$ sudo gem install pdfmd
``` 


## Applications

1. [exiftools](http://www.sno.phy.queensu.ca/~phil/exiftool/)

This is usually already in your os repositories

```
$ sudo yum install Perl-Image-Exiftool
```

2. [hiera](https://rubygems.org/gems/hiera) can be optionally used to configure
some default settings (instead of a configuration file).

```
$ gem install hiera
``` 

# Usage

The usage is quite simple:

```
$ ./pdfmd.rb [show|edit|rename|sort] [options] <filename>
```

The interface has been setup using Thor.  
So in order to get more information just run the required _help_ command:

``` 
$ pdfmd               # General information
$ pdfmd help <action> # Command specific help
```

My usual workflow is like this:

``` 
$ cd /my/pdf/directory            # Step 1
$ pdfmd show test.pdf             # Step 2
$ pdfmd edit -t all -r test.pdf   # Step 3
$ pdfmd sort .                    # Step 4
``` 

* _Step 1_: Change into the directory with the mess of pdf documents. Here all the files from the scanning before end up.
* _Step 2_: A quick look at the currently set metadata does not hurt. If I find the metadata already in order, I skip this document.
* _Step 3_: For each document I update the PDF metadata to the settings I prefer. The command `pdfmd explain <topic>` explains what the value are used for. Some parameters like _-r_ are actually ommited on my systems, because they have been set by Hiera.
* _Step 4_: In the end I sort all documents according to their metadata into correct subdirectories. The parameter _-d_ is being set from Hiera and makes sure the files end up where they are supposed to be.


There's an underlying logic in the renaming and sorting of the files according to the metadata. Make sure you read at least the help-information before you use it or it might be confusing.

It's also usefull to define some default settings in Hiera to avoid unnecessary typing.

__HINT__: Before you start using the script, make sure you have a backup of your files or you know what you're doing. If you loose information/files I will not be able to help you.


## Password protected files

_pdfmd_ recognises if a pdf file is password protected and will ask for the password.  
A password string can be defined in hiera that will be used per default.


# Hiera
 
In order for Hiera to provide (default) configuration data, setup a configuration hash e.g. inside the YAML backend:

``` YAML
pdfmd::config:
  default:
    password    : xxxxxxxxxx
  sort:
    destination : /data/tmp
    copy        : true
    interactive : false
  rename:
    #allkeywords : true # Does not make sense in combination with _keywords_
    keywords    : 2
    outputdir   : /data/output/sorted
    copy        : true
  edit:
    rename      : true

```

Information about which hiera configuration settings are available can be either found in `pdfmd help <command>` or `pdfmd explain hiera`.

**PDFMD** expects currently the hiera configuration file to be at `/etc/hiera.yaml`. With Hiera2 the default location has changed to `/etc/puppetlabs/code/hiera.yaml`. This might be addressed in a future version. Currently you have to create at least a symlink to `/etc/hiera.yaml`.

Test your hiera configuration with

``` bash
$ hiera pdfmd::config
``` 

# Contact

If you have improvements and suggestions -> let me know.

