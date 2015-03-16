# ruby-pmd
Pdf Meta data managing script

I use the script `pmd.rb`/pdfmetadata (with a slightly different name) to manage my PDF documents and keep the naming in line.  
Hidden deep in the directory structure of my disks I can quickly find the documents I need with a quick `find /document/path -type f -iname '*<keyword>*'`.

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

## Applications

1. [exiftools](http://www.sno.phy.queensu.ca/~phil/exiftool/)

This is usually already in your os repositories

```
$ sudo yum install Perl-Image-Exiftool
```

# Usage

The usage is quite simple

```
$ ./pmd.rb [show|edit|rename|sort] [options] <filename>
```

The interface has been setup using Thor.  
So in order to get more information just run the required _help_ command:

```
# Show general possibilities:
$ pdfmetadata.rb 

# Show more information about <action>
$ pdfmetadata.rb help <action>
```

__HINT__: Before you start using the script, make sure you have a backup of your files or you know what you're doing. If you loose information/files I will not be able to help you.

# Contact

If you have improvements and suggestions -> let me know.

