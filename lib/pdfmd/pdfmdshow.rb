# == Class: pdfmd.show
#
class Pdfmdshow < Pdfmd
  attr_accessor :filename

  @@show_filename = false 
  @@outputformat  = ''
  @@default_tags  = ['createdate', 'author', 'title', 'subject', 'keywords']

  def initialize(filename)
    super(filename)
    @filename = filename
  end


  # Define if the filename should be visible in the output
  def show_filename( enable = nil)
    @@show_filename = enable ? true : false
  end


  # Define the output format for showing the metadata
  def set_outputformat( format = 'yaml' )
    format.nil? ? format = 'yaml' : ''
    self.log('debug',"Output format set to '#{format}'.")
    @@outputformat = format
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

  # Return the provided metatags
  def show_metatags( tags = @@default_tags, format = @@outputformat, show_filename = @@show_filename )

    # Build the output hash from the tags matching the values in @@default_tags
    metadataOutputHash = Hash.new
    tags.each do |tagname|
      if @@metadata.has_key?(tagname)
        metadataOutputHash[tagname] = @@metadata[tagname]
      elsif tagname.downcase == 'all' # Exception when for keyword 'all'
        metadataOutputHash = @@metadata
      end
    end

    if show_filename
      metadataOutputHash['filename'] = @filename
    end

    # Return output well formatted
    case format
    when /hash/i
      self.log('info',"Showing metatags for '#{@filename}' in format 'hash'.")
      metadataOutputHash
    when /csv/i
      csvData = Hash.new
      metadataOutputHash.keys.each do |tagname|
        csvData[tagname] = '"' + metadataOutputHash[tagname.downcase].to_s.gsub(/"/,'""') + '"'
      end
      self.log('info',"Showing metatags for '#{@filename}' in format 'csv'.")
      csvData.values.join(',')
    when /json/i
      require 'json'
      self.log('info',"Showing metatags for '#{@filename}' in format 'json'.")
      metadataOutputHash.to_json
    else 
      require 'yaml'
      self.log('info',"Showing metatags for '#{@filename}' in format 'yaml'.")
      metadataOutputHash.to_yaml
    end

  end

end
