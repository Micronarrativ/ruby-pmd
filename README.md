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
# Show general possibilities:
$ pdfmd 

# Show more information about <action>
$ pdfmd help <action>
```

My usual workflow is like this:

``` 
$ pdfmd show test.pdf
$ pdfmd edit -t all test.pdf
  ...
$ pdfmd rename test.pdf
$ mv 20150101-me-dok-testdocument.pdf /my/pdf/directory
  ...
$ pdfmd sort .
``` 

There's an underlogic in the renaming and sorting of the files according to the metadata. Make sure you read at least the help-information before you use it.

It's also usefull to define some default settings in Hiera to avoid unnecessary typing.

__HINT__: Before you start using the script, make sure you have a backup of your files or you know what you're doing. If you loose information/files I will not be able to help you.

# Hiera

In order for Hiera to provide (default) configuration data, setup a configuration hash e.g. inside the YAML backend:

``` YAML
pdfmd::config:
  sort:
    destination : /data/tmp
    copy        : true
    log         : true
    logfilepath : /var/log/pdfmd.log # Needs create/write rights on this file
    interactive : false
  rename:
    #allkeywords : true # Does not make sense in combination with _keywords_
    keywords    : 2
    outputdir   : /data/output/sorted
    copy        : true

```

Information about which hiera configuration settings are available can be either found in `pdfmd help <command>` or `pdfmd explain hiera`.

Test your hiera configuration with

``` bash
$ hiera pdfmd::config
``` 

# Contact

If you have improvements and suggestions -> let me know.

