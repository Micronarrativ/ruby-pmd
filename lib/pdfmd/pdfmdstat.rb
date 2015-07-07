# == Class: pdfmdstat
#
# gather and store statistical information
# about pdf documents
require_relative './pdfmdmethods.rb'

class Pdfmdstat

  # Include unspecific methods for Pdfmd
  include Pdfmdmethods

  attr_accessor :metadata

  @statdata   = {}
  @hieradata  = {}

  def initialize(metadata)

    @default_tags = ['author', 'title', 'subject', 'createdate', 'keywords']
    @statdata = {
      'author' => {},
      'createdate' => {},
      'title' => {},
      'subject' => {},
      'keywords' => {},
    }
    @statdata = count_values(metadata,@default_tags)
  end

  #
  # Method to set tags
  def tags(metatagnames)

    if metatagnames.is_a?(String)
      @default_tags = metatagnames.split(',')
      self.log('debug', "Setting tags for statistic to '#{metatagnames}'.")
    elsif !metatagnames.nil?
      self.log('error', 'Unkown Tag definition. Exit.')
      exit 1
    end

  end

  # Counting all values provided as hash in metadata
  # Optional keynames can be handed over as an array
  def count_values(metadata, keys = '')

    data = Hash.new
    if keys == ''
      data = {
        'author' => {},
        'title' => {},
        'createdate' => {},
        'subject' => {},
        'keywords' => {},
      }
    elsif keys.is_a?(Array)

      keys.each do |keyname|
        data[keyname] = {}
      end

    else
      puts 'invalid keys provided'
      exit 1
    end

    # Iterate through all metadata and
    # count how often the metadata shows up in each
    # category
    metadata.each do |value|

      # Iterate through all metadata tags and count
      datahash = eval value[1]
      datahash.keys.each do |tagkey|

        datahash[tagkey].nil? ? next : ''
        if data[tagkey][datahash[tagkey]].nil?
          data[tagkey][datahash[tagkey]] = 1
        else
          data[tagkey][datahash[tagkey]] = data[tagkey][datahash[tagkey]] + 1
        end
      end
    end

    data

  end

  #
  # Run statistical overview about the metadata
  # Count all values in the metatags and summ them up
  def analyse_metadata()

    outputHash = Hash.new
    @default_tags.sort.each do |tagname|
      outputHash[tagname.capitalize] = @statdata[tagname]
    end

    sortedOutputHash = Hash.new
    outputHash.each do |metatag,statdata|

      sortedstatdata = Hash.new
     statdata = statdata.sort.each do |title, amount|
       title = title.empty? ? '*empty*' : title
       sortedstatdata[title] = amount
     end

     sortedOutputHash[metatag] = sortedstatdata

    end

    puts sortedOutputHash.to_yaml.gsub(/---\n/,'')

  end

end
