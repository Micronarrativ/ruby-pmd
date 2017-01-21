# == Class: pdfmd.show
#
class Pdfmdshow < Pdfmd
  attr_accessor :filename

  @@default_tags  = ['createdate', 'author', 'title', 'subject', 'keywords']

  # Initialize the class. Nothing happens here.
  def initialize
  end

  # Overvwrite the tags
  def set_tags( tags = @@default_tags)

    if tags

      # Tags can be specified as array or string
      #
      case tags.class.to_s
      when /array/i
        @@default_tags = tags
      when /string/i
        @@default_tags = tags.split(/,\s+/)
      end

    end

  end

  # Correct the date fields in a given hash
  # This error is comming from the way pdf documents lists the dates in the format
  # yyyy:mm:dd hh:mm:dd instead of 'yyyy-mm-d hh:mm:ss'.
  # # Test covered
  def show_corrected_date_format(input_hash)

    if input_hash['createdate'] =~ /^(\d{4}):(\d{2}):(\d{2})/
      input_hash['createdate'] = input_hash['createdate'].gsub(/^(\d{4}):(\d{2}):(\d{2})/,'\1-\2-\3')
    end
    input_hash

  end

  # Return the provided metatags
  # def show_metatags( tags = @@default_tags, format = @@outputformat, show_filename = @@show_filename )
  def show_metatags(options = {})

    if options[:tag].nil? or !options[:tag]
      tags = DEFAULT_TAGS
    else
      tags = options[:tag]
    end

    if options[:format].nil? or !options[:format]
      format = 'yaml'
    else
      format = options[:format]
    end

    if options[:includepdf]
      show_filename = true
    else
      show_filename = false
    end

    # Build the output hash from the tags matching the values in @@default_tags
    metadataOutputHash = Hash.new
    tags.each do |tagname|
      if @@metadata.has_key?(tagname)
        metadataOutputHash[tagname] = @@metadata[tagname]
      elsif tagname.downcase == 'all' # Exception when for keyword 'all'
        metadataOutputHash = @@metadata
      end
    end

    metadataOutputHash = show_corrected_date_format(metadataOutputHash)

    if show_filename
      metadataOutputHash['filename'] = @filename
    end

    # Return output well formatted
    case format
    when /hash/i
      Pdfmdmethods.log('info',"Showing metatags for '#{@filename}' in format 'hash'.")
      metadataOutputHash
    when /csv/i
      csvData = Hash.new
      metadataOutputHash.keys.each do |tagname|
        csvData[tagname] = '"' + metadataOutputHash[tagname.downcase].to_s.gsub(/"/,'""') + '"'
      end
      Pdfmdmethods.log('info',"Showing metatags for '#{@filename}' in format 'csv'.")
      csvData.values.join(',')
    when /json/i
      require 'json'
      Pdfmdmethods.log('info',"Showing metatags for '#{@filename}' in format 'json'.")
      metadataOutputHash.to_json
    else 
      require 'yaml'
      Pdfmdmethods.log('info',"Showing metatags for '#{@filename}' in format 'yaml'.")
      metadataOutputHash.to_yaml
    end

  end

end
