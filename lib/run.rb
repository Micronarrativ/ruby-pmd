#!/usr/bin/env ruby
require './pdfmd.rb'
require './pdfmd/pdfmdstat.rb'
require "thor"

VERSION = '2.1.2'
NAME    = 'pdfmd'

#
# Read the content of the long description from an external file
#
def readLongDesc(filename)

  paths = [
    "#{File.dirname(File.expand_path($0))}../lib",
    "#{Gem.dir}/gems/#{NAME}-#{VERSION}/lib",
  ]

  longDescContent = ''
  paths.each do |value|
    if File.exists?(value + '/' + filename)

      File.open(value + '/' + filename, 'r') do |infile|
        while (line = infile.gets)
          longDescContent = longDescContent + line
        end
      end

    end
  end

  longDescContent


end

#
# Thor class
class DOC < Thor

  # Class options for all commands (logging only)
  # none

  #
  # Show the current metadata tags
  #
  desc 'show', 'Show metadata of a file'
  long_desc readLongDesc 'pdfmd/long_desc.pdfmdshow.txt'
  method_option :tag, :type => :string, :aliases => '-t', :desc => 'Show specific tag(s), comma separated', :required => false
  method_option :format, :type => :string, :aliases => '-f', :desc => 'Define output format', :required => false
  method_option :includepdf, :type => :boolean, :aliases => '-i', :desc => 'Include the filename in output', :required => false
  def show(*filename)

    filename.each do |current_file|

      # Skip non-pdf documents
      ! File.extname(current_file).match(/\.pdf/) ? next : ''

      pdfdoc            = Pdfmdshow.new current_file
      format            = pdfdoc.determineValidSetting(options[:format], 'show:format')
      show_filename     = pdfdoc.determineValidSetting(options[:includepdf], 'show:includepdf')
      show_tags         = pdfdoc.determineValidSetting(options[:tag], 'show:tags')
      pdfdoc.set_outputformat format
      pdfdoc.show_filename show_filename
      pdfdoc.set_tags show_tags
      puts pdfdoc.show_metatags

      pdfdoc            = ''

    end
  end

  # Clean all metadata from a document
  #
  desc 'clean', 'Clean metadata from file'
  long_desc readLongDesc 'pdfmd/long_desc.pdfmdclean.txt'
  method_option :tags, :aliases => '-t', :type => :string, :required => false
  def clean(*filename)

    filename.each do |current_file|

      # Skip non-pdf documents
      ! File.extname(current_file).match(/\.pdf/) ? next : ''

      pdfdoc      = Pdfmdclean.new current_file
      pdfdoc.tags = options[:tags]
      pdfdoc.run

      # Unset
      pdfdoc      = ''

    end
  end


  # Show current settings
  #
  desc 'config', 'Show config defaults'
  long_desc readLongDesc 'pdfmd/long_desc.pdfmdconfig.txt'
  method_option :show, :type => :boolean, :aliases => '-s', :required => false
  def config(subcommand = '')

    pdfdoc = Pdfmdconfig.new ''
    puts pdfdoc.show_config subcommand

  end

  #
  # Change a MetaTag Attribute
  #
  desc 'edit', 'Edit Meta Tag(s)'
  long_desc readLongDesc 'pdfmd/long_desc.pdfmdedit.txt'
  method_option :tag, :type => :string, :aliases => '-t', :desc => 'Name of the Tag(s) to Edit', :required => true, :lazy_default => 'all'
  method_option :rename, :type => :boolean, :aliases => '-r', :desc => 'Rename file after changing meta-tags', :required => false
  method_option :opendoc, :type => :boolean, :aliases => '-o', :desc => 'Open the PDF document in a separate window.', :required => false, :lazy_default => true
  def edit(*filename)

    filename.each do |current_file|

      # Skip non-pdf documents
      ! File.extname(current_file).match(/\.pdf/) ? next : ''

      pdfdoc            = Pdfmdedit.new current_file
      tags              = pdfdoc.determineValidSetting(options[:tag],'edit:tags')
      pdfdoc.opendoc    = pdfdoc.determineValidSetting(options[:opendoc], 'edit:opendoc')
      pdfdoc.pdfviewer  = pdfdoc.determineValidSetting(nil, 'edit:pdfviewer')
      pdfdoc.set_tags tags
      pdfdoc.update_tags
      pdfdoc.write_tags current_file

      # If the file shall be renamed at the same time, trigger the other task
      if pdfdoc.determineValidSetting(options[:rename], 'edit:rename')

        #rename filename
        pdfdoc.log('info', 'Running rename command.')
        rename current_file

      end

      # Unset the object
      pdfdoc = ''

    end

  end

  #
  # Show statistics
  #
  desc 'stat', 'Show metadata statistics of multiple files'
  long_desc readLongDesc 'pdfmd/long_desc.pdfmdstat.txt'
  option :recursive, :type => :boolean, :aliases => '-r', :desc => 'Include subdirectories recursively.', :lazy_default => true, :required => false
  option :tags, :aliases => '-t', :type => :string, :desc => 'Define Metatags to run at', :lazy_default => 'author,title,subject,createdate,keywords', :required => false
  def stat(input)

    filemetadata  = Hash.new
    currentOutput = Hash.new

    if File.file?(input)
      puts 'Input is a single file.'
      puts 'n.a.y.'
    else

      # Iterate through all Files an collect the metadata
      recursive = options[:recursive] ? '/**' : ''

      # Count the number of files quickly to show an overview
      # nooFiles = numberOfFiles
      nooFiles = Dir[File.join(input.chomp, recursive, '*.pdf')].count { |file| File.file?(file) }
      currentNooFiles = 0
      Dir.glob("#{input.chomp}#{recursive}/*.pdf").each do |filename|

        # Print percentage
        currentNooFiles = currentNooFiles + 1
        percentage = 100 / nooFiles * currentNooFiles
        print "\r Status: #{percentage} % of #{nooFiles} files processed.   "

        pdfdoc = Pdfmd.new filename
        filemetadata = {}
        currentOutput[File.basename(filename)] = pdfdoc.metadata.to_s
        pdfdoc = nil

      end
      puts ''
      puts ''

      pdfstat = Pdfmdstat.new(currentOutput)
      pdfstat.tags options[:tags]
      pdfstat.analyse_metadata

    end

  end

  #
  # Sort the files into directories based on the author
  #
  desc 'sort','Sort files into directories sorted by Author'
  long_desc readLongDesc 'pdfmd/long_desc.pdfmdsort.txt'
  method_option :destination, :aliases => '-d', :required => false, :type => :string, :desc => 'Defines the output directory'
  method_option :copy, :aliases => '-c', :required => false, :type => :boolean, :desc => 'Copy files instead of moving them'
  method_option :interactive, :aliases => '-i', :required => false, :type => :boolean, :desc => 'Enable/Disable interactive sorting'
  method_option :overwrite, :alises => '-o', :required => false, :type => :boolean, :desc => 'Enable/Disable file overwrite.', :lazy_default => true
  method_option :dryrun, :aliases => '-n', :required => false, :type => :boolean, :desc => 'Run without changing something'
  def sort(input)

    if File.file?(input)
      pdfdoc              = Pdfmdsort.new input
      pdfdoc.copy         = pdfdoc.determineValidSetting(options[:copy], 'sort:copy')
      pdfdoc.interactive  = pdfdoc.determineValidSetting(options[:interactive], 'sort:interactive')
      pdfdoc.destination  = pdfdoc.determineValidSetting(options[:destination], 'sort:destination')
      pdfdoc.overwrite    = pdfdoc.determineValidSetting(options[:overwrite], 'sort:overwrite')
      pdfdoc.dryrun       = pdfdoc.determineValidSetting(options[:dryrun], 'sort:dryrun')
      pdfdoc.sort
    else

      # Run the actions for all files
      Dir.glob(input.chomp + '/*.pdf').each do |filename|
        pdfdoc              = Pdfmdsort.new filename
        pdfdoc.copy         = pdfdoc.determineValidSetting(options[:copy], 'sort:copy')
        pdfdoc.interactive  = pdfdoc.determineValidSetting(options[:interactive], 'sort:interactive')
        pdfdoc.destination  = pdfdoc.determineValidSetting(options[:destination], 'sort:destination')
        pdfdoc.overwrite    = pdfdoc.determineValidSetting(options[:overwrite], 'sort:overwrite')
        pdfdoc.dryrun       = pdfdoc.determineValidSetting(options[:dryrun], 'sort:dryrun')
        pdfdoc.sort
      end

    end

  end


  # Rename the file according to the Metadata
  #
  # Scheme: YYYYMMDD-author-subject-keywords.extension
  # this is messing up the logging and creates two different files
  desc 'rename', 'Rename the file according to Metadata'
  long_desc readLongDesc('pdfmd/long_desc.pdfmdrename.txt')
  method_option :dryrun, :type => :boolean, :aliases => '-n', :desc => 'Run without making changes', :required => false
  method_option :allkeywords, :type => :boolean, :aliases => '-a', :desc => 'Add all keywords (no limit)', :required => false, :lazy_default => true
  method_option :nrkeywords, :type => :string, :aliases => '-k', :desc => 'Number of keywords to include (Default: 3)', :required => false
  method_option :outputdir, :aliases => '-o', :type => :string, :desc => 'Specify output directory', :required => false
  method_option :copy, :aliases => '-c', :type => :boolean, :desc => 'Copy instead of moving the file when renaming', :lazy_default => true
  def rename(*filename)

    filename.each do |current_file|

      # Skip non-pdf documents
      ! File.extname(current_file).match(/\.pdf/) ? next : ''

      pdfdoc                = Pdfmdrename.new current_file
      pdfdoc.dryrun         = pdfdoc.determineValidSetting(options[:dryrun],'rename:dryrun')
      pdfdoc.allkeywords    = pdfdoc.determineValidSetting(options[:allkeywords],'rename:allkeywords')
      pdfdoc.outputdir      = pdfdoc.determineValidSetting(options[:outputdir], 'rename:outputdir')
      if nrkeywords = pdfdoc.determineValidSetting(options[:nrkeywords], 'rename:nrkeywords' )
        pdfdoc.nrkeywords = nrkeywords
      end
      pdfdoc.copy           = pdfdoc.determineValidSetting(options[:copy], 'rename:copy')
      pdfdoc.rename

      # Unset
      pdfdoc                = ''

    end

  end

  #
  # One parameter to show the current version
  #
  map %w[--version -v] => :__print_version
  desc "--version, -v", 'Show the current script version'
  def __print_version
    puts VERSION
  end

  map %w[--revision -r] => :__print_revision
  desc "--revision, -r", 'Show the revision of the gem'
  def __print_createdate
    metadata = YAML.load(`gem specification pdfmd metadata`)
    puts metadata['revision']
  end

end

DOC.start
