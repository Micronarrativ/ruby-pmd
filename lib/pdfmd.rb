#!/usr/bin/env ruby
# == File: pdfmd.rb
#
# Show and edit Metadata of PDF files and rename the files accordingly.
#
# === Requirements
#
# ==== Ruby gems:
# - thor
# - highline/import
# - fileutils
# - i18n
# - pathname
# - logger
#
# ==== OS applications:
#
# - exiftools
#
# === Usage
#
#   $ ./pdfmd <action> <parameter> file
#
#   $ ./pdfmd help <action>
#
# An overview about the actions can be seen when running the script without
# any parameters
#
# Check and set metadata of PDF documents
# 
# A complete set of metada contains
#
# * CreateDate
# * Title
# * Author
# * Subject
# * Keywords (optional)
#
# TODO: Include password protected PDF documents as well
# TODO: Fix broken PDF files automatically
# TODO: Enable logging in 'edit'
# TODO: Read this: http://lostechies.com/derickbailey/2011/04/29/writing-a-thor-application/
# TODO: ... and this: http://blog.paracode.com/2012/05/17/building-your-tools-with-thor/
# gs \
#   -o repaired.pdf \
#   -sDEVICE=pdfwrite \
#   -dPDFSETTINGS=/prepress \
#   corrupted.pdf
#
# == Author
#
# Daniel Roos <daniel-git@micronarrativ.org>
# Source: https://github.com/Micronarrativ/ruby-pmd
#
require "thor"
require "highline/import"
require "fileutils"
require "i18n"
require 'pathname'
require 'logger'

VERSION = '1.6.3'

# Include general usage methods
require_relative('pdfmd/methods.rb')

class DOC < Thor

  #
  # Show the current metadata tags
  #
  # TODO: format output as JSON and YAML
  # TODO: Enable additional options
  # TODO: Add command to show current settings (from hiera)
  #
  desc 'show', 'Show metadata of a file'
  method_option :all, :type => :boolean, :aliases => '-a', :desc => 'Show all metatags', :default => false, :required => false
  method_option :tag, :type => :string, :aliases => '-t', :desc => 'Show specific tag(s), comma separated', :required => false
  #method_option :format, :type => :string, :aliases => '-f', :desc => 'Define output format', :required => false
  long_desc <<-LONGDESC
  == General

  Show metatags of a PDF document.

  The following tags are being shown:
  \x5 * Author
  \x5 * Creator
  \x5 * CreateDate
  \x5 * Title
  \x5 * Subject
  \x5 * Keywords

  == Parameters

  --all, -a
  \x5 Show all relevant metatags for a document.

  Relevant tags are Author,Creator, CreateDate, Title, Subject, Keywords.

  --tag, -t
  \x5 Specify the metatag to show. The selected metatag must be one of the relevant tags. Other tags are ignored and nothing is returned.

  The value for the parameter is case insensitive: 'Author' == 'author'

  == Example

  # Show default metatags for a pdf document
  \x5>CLI show <filename>

  # Show default metatags for example.pdf
  \x5>CLI show example.pdf

  # Show value for metatag 'Author' for the file example.pdf
  \x5>CLI show -t author example.pdf

  # Show value for metatags 'Author','Title' for the file example.pdf
  \x5>CLI show -t author,title example.pdf

  LONGDESC
  def show(filename)

    ENV['PDFMD_FILENAME'] = filename
    ENV['PDFMD_TAGS']     = options[:tag]
    ENV['PDFMD_ALL']      = options[:all].to_s
    require_relative('./pdfmd/show.rb')

  end

  #
  # Show current settings
  #
  desc 'config', 'Show config defaults'
  long_desc <<-LONGDESC

  LONGDESC
  method_option :show, :type => :boolean, :aliases => '-s', :required => false
  def config

    ENV['PDFMD_SHOW'] = options[:show].to_s
    require_relative('./pdfmd/config.rb')

  end

  #
  # Change a MetaTag Attribute
  #
  # TODO: keywords are added differently according to the documentation
  # http://www.sno.phy.queensu.ca/~phil/exiftool/faq.html
  desc 'edit', 'Edit Meta Tag(s)'
  long_desc <<-LONGDESC
  == General

  Command will edit the metadata of a PDF document. Multiple values can be
  specified or 'all'.

  The command will invoke an interactive user input and request the values
  for the metatag if no value is provided.

  Additionally the file can be renamed at the end according to the new meta
    tags. See `$ #{__FILE__} help rename` for details.

  == Parameters

  --tag, -t
  \x5 Names or list of names of Metatag fields to set, separated by commata.

  If a value is provided, the current Value will be replaced by the new value.

  --rename, -r
  \x5 Rename file after updating the meta tag information according to the fields.

  This parameter is identical to running `> CLI rename <filename>`

  Hiera parameter: rename

  General example:

  # Edit tag 'TAG' and set a new value interactive.
  \x5>CLI edit -t TAG <filename>

  # Edit tag 'Author' and set new value interactive.
  \x5>CLI edit -t author example.pdf

  # Edit multiple Tags and set a new value interactive.
  \x5>CLI edit -t tag1,tag2,tag3 <filename>

  # Edit multiple Tags and set a new value in batch mode.
  \x5 CLI edit -t tag1='value1',tag2='value2' <filename>

  == Multiple Tags

  For setting multiple tags list the tags comma separated.

  For setting all tags (Author, Title, Subject, CreateDate, Keywords) use the keyword 'all' as tagname.

  # Set tags 'Author', 'Title', 'Subject' in example.pdf interactivly.
  \x5>CLI edit -t author,title,subject example.pdf`

  # Set tags 'Author', 'Title', 'Subject', 'CreateDate', 'Keywords' in
  example.pdf interactive:
  \x5>CLI edit -t all example.pdf

  # Set tags 'Author', 'CreateDate' in example.pdf in batch mode (non-interactive:

  CLI edit -t author='Me',createdate='1970:00:00 01:01:01' example.pdf
  CLI edit -t author='Me',Createdate=19700000 example.pdf

  == Tag: CreateDate

  In order to enter a value for the 'CreateDate' field, some internal matching is going on in order to make it easier and faster to enter dates and times.

  The following formats are identified/matched:

  \x5 yyyymmdd
  \x5 yyyymmd
  \x5 yyyymmddHHMMSS
  \x5 yyyy-mm-dd HH:MM:SS
  \x5 yyyy:mm:dd HH:MM:SS
  \x5 yyyy.mm.dd HH:MM:SS
  \x5 yyyy-mm-d
  \x5 yyyy-mm-dd
  \x5 yyyy.mm.d
  \x5 yyyy.mm.dd
  \x5 yyyy:mm:d
  \x5 yyyy:mm:dd

  \x5 - If HH:MM:SS or HHMMSS is not provided, those values are automatically set to zero.
  \x5 - The output format of every timestamp is <yyyy:mm:dd HH:MM:SS>
  \x5 - When providing and invalid date, the incorrect date is rejected and the user asked to provide the correct date.

  == Rename file

  In addition to setting the tags the current file can be renamed according to
  the new metadata.

  # Set tag 'Author' and rename file example.pdf
  \x5> CLI edit -t author -r example.pdf

  See `> CLI help rename` for details about renaming.

  To enable this feature in hiera add the key 'rename' into the section 'edit' with the value 'true'.

  LONGDESC
  method_option :tag, :type => :string, :aliases => '-t', :desc => 'Name of the Tag(s) to Edit', :default => false, :required => true
  method_option :rename, :type => :boolean, :aliases => '-r', :desc => 'Rename file after changing meta-tags', :default => false, :required => false
  method_option :log, :aliases => '-l', :type => :boolean, :desc => 'Enable logging'
  method_option :logfile, :aliases => '-p', :type => :string, :desc => 'Define path to logfile'
  def edit(filename)

    ENV['PDFMD_FILENAME'] = filename
    ENV['PDFMD_TAG']      = options[:tag]
    ENV['PDFMD_RENAME']   = options[:rename].to_s
    ENV['PDFMD']          = __FILE__
    ENV['PDFMD_LOG']      = options[:log].to_s
    ENV['PDFMD_LOGFILE']  = options[:logfile]

    require_relative('./pdfmd/edit.rb')

  end

  #
  # Check the metadata for the minium necessary tags
  # See documentation at the top of this file for defailts
  #
  # void check(string)
  desc 'check', 'Check Metadata for completeness'
  long_desc <<-LONGDESC
  == General

  Show value of the following metatags of a PDF document:

  - Author
  \x5- Creator
  \x5- CreateDate
  \x5- Subject
  \x5- Title
  \x5- Keywords

  == Example

  # Show the values of the metatags for example.pdf
  \x5>CLI show example.pdf

  LONGDESC
  def check(filename)

    ENV['PDFMD_FILENAME'] = filename
    require_relative('./pdfmd/check.rb')

  end

  #
  # Explain fields and Metatags
  # Show information about how they are used.
  #
  desc 'explain','Show more information about usuable Meta-Tags'
  long_desc <<-LONGDESC
  == General

  Explain some terms used with the script.

  == Example

  # Show the available subjects
  \x5>CLI explain

  # Show information about the subject 'author'
  \x5>CLI explain author

  LONGDESC
  def explain(term='')

    ENV['PDFMD_EXPLAIN']  = term
    ENV['PDFMD']          = File.basename(__FILE__)
    require_relative('./pdfmd/explain.rb')

  end

  #
  # Sort the files into directories based on the author
  #
  desc 'sort','Sort files into directories sorted by Author'
  long_desc <<-LONGDESC
  == General

  Will sort pdf documents into subdirectories according to the value of their
  tag 'author'.

  When using this action a logfile with all actions will be generated in the
  current working directory with the same name as the script and the ending
  '.log'. This can be disabled with the parameter 'log' if required.

  If a document does not have an entry in the meta tag 'author', the file will
  not be processed. This can be seen in the output of the logfile as well.

  === Parameters

  [*destination|d*]
  \x5 Speficy the root output directory to where the folderstructure is being created.

    This parameter is required if hiera is not configured.

    This parameter overwrites the hiera defaults

  [*copy|c*]
  \x5 Copy the files instead of moving them.

  [*log|l*]
  \x5 Disable/Enable the logging.

  Default: enabled.

  [*logfile|p*]
  \x5 Set an alternate path for the logfile. If not path is chosen, the logfile
  is being created in the current working directory as `pdfmd.log`.

  [*interactive|i*]
  \x5 Disable/Enable interactive sorting. This will ask for confirmation for each sorting action.

  Default: disabled.



  === Replacement rules

  The subdirectories for the documents are generated from the values in the
  tag 'author' of each document.

  In order to ensure a clean directory structure, there are certain rules
  for altering the values.
  \x5 1. Whitespaces are replaced by underscores.
  \x5 2. Dots are replaced by underscores.
  \x5 3. All letters are converted to their lowercase version.
  \x5 4. Special characters are serialized

  === Hiera configuration

  Set the default values mentioned below as sub-hash of the main configuration:

  YAML
  \x5sort:
  \x5  key: value

  See the README file for an example how to define the values in Hiera.

  === Hiera defaults

  The following values can be influenced by the hiera configuration in the section 'sort'. Commandline parameter will overwrite the defaults coming from hiera unless otherwise notet.

  [*copy*]
  \x5  If set to true copies the files from the source directory instead of moving them.

  [*destination*]
  \x5  Specifies the default output directory (root-directory). Either this or the command line parameter for destinations must be set.

  [*log*]
  \x5 Enables (true) or disables (false) logging.

  [*logfile*]
  \x5 Specifes the default path for the logfile. If no path is set and logging is enable, the logfile will be created in the current working directory.

  Default is the current working directory with the filename `pdfmd.log`

  [*interactive*]
  \x5 If set to true, each file must be acknowledged to be processed when running the script.

  === Example

    This command does the following:
    \x5 1. Take all pdf documents in the subdirectory ./documents.
   \x5 2. Create the output folder structure in `/tmp/test/`.
   \x5 3. Copy the files instead of moving them.
   \x5 4. Disable the logging.
   \x5> CLI sort -d /tmp/test -c -l false ./documents

  LONGDESC
  method_option :destination, :aliases => '-d', :required => false, :type => :string, :desc => 'Defines the output directory'
  method_option :copy, :aliases => '-c', :required => false, :type => :boolean, :desc => 'Copy files instead of moving them'
  method_option :log, :aliases => '-l', :required => false, :type => :boolean, :desc => 'Enable/Disable creation of log files'
  method_option :logfile, :aliases => '-p', :required => false, :type => :string, :desc => 'Change the default logfile path'
  method_option :interactive, :aliases => '-i', :required => false, :type => :boolean, :desc => 'Enable/Disable interactive sorting'
  method_option :dryrun, :aliases => '-n', :required => false, :type => :boolean, :desc => 'Run without changing something'
  def sort(inputDir)

    ENV['PDFMD_INPUTDIR']     = inputDir
    ENV['PDFMD_DESTINATION']  = options[:destination].to_s
    ENV['PDFMD_COPY']         = options[:copy].to_s
    ENV['PDFMD_LOG']          = options[:log].to_s
    ENV['PDFMD_LOGFILEPATH']  = options[:logfile].to_s
    ENV['PDFMD_INTERACTIVE']  = options[:interactive].to_s
    ENV['PDFMD_DRYRUN']       = options['dryrun'].to_s
    ENV['PDFMD']              = __FILE__
    require_relative('./pdfmd/sort.rb')

  end

  #
  # Rename the file according to the Metadata
  #
  # Scheme: YYYYMMDD-author-subject-keywords.extension
  desc 'rename', 'Rename the file according to Metadata'
  long_desc <<-LONGDESC
  == General

  Rename a file with the meta tags in the document.

  == Parameter

  --dry-run, -n
  \x5 Simulate the renaming process and show the result without changing the file.

  --all-keywords, -a
  \x5 Use all keywords from the meta information in the file name and ignore the limit.

  Hiera parameter: allkeywords [true|false]

  Default: false

  --keywwords, -k
  \x5 Set the number of keywords used in the filename to a new value.

  Hiera parameter: keywords <integer>

  Default: 3 

  --outputdir, -o
  \x5 Rename the file and move it to the directory defined in '--outputdir'.

  Hiera parameter: outputdir </file/path/>

  Default: current file directory

  --copy, -c
  \x5 Copy the file instead of moving it to the new name or destination.

  Hiera parameter: copy [true|false]

  Default: false

  The directory must exist at runtime.

  --log, -l
  \x5 Enable logging.

  Values: true|false

  --logfile, -p
  \x5 Define logfile path

  Default: current working-dir/pdfmd.log

  == Example

  # Rename the file according to the metatags
  \x5> CLI rename <filename>

  # Rename example.pdf according to the metatags
  \x5> CLI rename example.pdf

  # Simulate renaming example.pdf according to the metatags (dry-run)
  \x5> CLI rename -n example.pdf

  == Rules

  There are some rules regarding how documents are being renamed

  Rule 1: All documents have the following filenaming structure:

  <yyyymmdd>-<author>-<type>-<additionalInformation>.<extension>

  \x5 # <yyyymmdd>: Year, month and day identival to the meta information in the
  document.
  \x5 # <author>: Author of the document, identical to the meta information
  in the document. Special characters and whitespaces are replaced.
  \x5 # <type>: Document type, is being generated from the title field in the metadata of the document. Document type is a three character abbreviation following the following logic:

  \x5 til => Tilbudt|Angebot
  \x5 odb => Orderbekreftelse
  \x5 fak => Faktura
  \x5 ord => Order
  \x5 avt => Kontrakt|Avtale|Vertrag|contract
  \x5 kvi => Kvittering
  \x5 man => Manual
  \x5 bil => Billett|Ticket
  \x5 inf => Informasjon|Information
  \x5 dok => unknown

  If the dokument type can not be determined automatically, it defaults to 'dok'.

  # <additionalInformation>: Information generated from the metadata fields
  'title', 'subject' and 'keywords'. 

  If 'Title' or 'Keywords' contains one of the following keywords, the will be replaced with the corresponding abbreviation followed by the specified value separated by a whitespace:

  \x5 fak => Faktura|Fakturanummer|Rechnung|Rechnungsnummer
  \x5 kdn => Kunde|Kundenummer|Kunde|Kundennummer
  \x5 ord => Ordre|Ordrenummer|Bestellung|Bestellungsnummer
  \x5 kvi => Kvittering|Kvitteringsnummer|Quittung|Quittungsnummer

  Rule 2: The number of keywords used in the filename is defined by the parameter '-k'. See the section of that parameter for more details and the default value.

  Rule 3: Keywords matching 'kvi','fak','ord','kdn' are prioritised.

  Rule 4: Special characters and whitespaces are replaced: 

  \x5 ' ' => '_'
  \x5 '/' => '_'

  Rule 5: The new filename has only lowercase characters.

  == Example (detailed)

  # Example PDF with following MetaTags:
  
  \x5 Filename   : example.pdf
  \x5 Author     : John
  \x5 Subject    : new Product
  \x5 Title      : Presentation
  \x5 CreateDate : 1970:01:01 01:00:00
  \x5 Keywords   : John Doe, Jane Doe, Mister Doe

  # Renaming the file
  \x5> CLI rename example.pdf
  \x5 example.pdf => 19700101-john-dok-new_product-john_doe-jane_doe.pdf

  # Simulation to rename the file (no actual change)
  \x5> CLI rename -n example.pdf
  \x5example.pdf => 19700101-john-dok-new_product-john_doe-jane_doe.pdf

  # Renaming the file with all keywords
  \x5> CLI rename -n -a example.pdf

  \x5 example.pdf => 19700101-john-dok-new_product-john_doe-jane_doe-mister_doe.pdf

  LONGDESC
  method_option :dryrun, :type => :boolean, :aliases => '-n', :desc => 'Run without making changes', :default => false, :required => false
  method_option :allkeywords, :type => :boolean, :aliases => '-a', :desc => 'Add all keywords (no limit)', :required => false
  method_option :keywords, :type => :numeric, :aliases => '-k', :desc => 'Number of keywords to include (Default: 3)', :required => false
  method_option :outputdir, :aliases => '-o', :type => :string, :desc => 'Speficy output directory', :default => false, :required => :false
  method_option :copy, :aliases => '-c', :type => :boolean, :desc => 'Copy instead of moving the file when renaming'
  method_option :log, :aliases => '-l', :type => :boolean, :desc => 'Enable logging'
  method_option :logfile, :aliases => '-p', :type => :string, :desc => 'Define path to logfile'
  def rename(filename)

    ENV['PDFMD_FILENAME']       = filename
    ENV['PDFMD_DRYRUN']         = options[:dryrun].to_s
    ENV['PDFMD_ALLKEYWORDS']    = options[:allkeywords].to_s
    ENV['PDFMD_OUTPUTDIR']      = options[:outputdir].to_s
    ENV['PDFMD_NUMBERKEYWORDS'] = options[:keywords].to_s
    ENV['PDFMD_COPY']           = options[:copy].to_s
    ENV['PDFMD_LOG']            = options[:log].to_s
    ENV['PDFMD_LOGFILE']        = options[:logfile].to_s
    ENV['PDFMD']                = __FILE__
    require_relative('./pdfmd/rename.rb')

  end

  #
  # One parameter to show the current version
  #
  map %w[--version -v] => :__print_version
  desc "--version, -v", 'Show the current script version'
  def __print_version
    puts VERSION
  end

end

DOC.start

