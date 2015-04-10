# == File: methods.rb
#
# General methods for supporting smaller tasks of the Thor commands

#
# Query Hiera installation
# I don't give a sh** about cross platform at this point.
#
# Return the hash of the hiera values or false (if no hiera is found)
#
def queryHiera(keyword,facts = 'UNSET')

  # Set default facts
  facts == 'UNSET' ? facts = "fqdn=#{`hostname`}" : ''

  # If hiera isn't found, return false
  # otherwise return the hash
  if !system('which hiera > /dev/null 2>&1')
    puts 'Cannot find "hiera" command in $path.'
    return false
  else
    return eval(`hiera #{keyword} #{facts}`)
  end

end



#
# Set Keywords Preface based on title and subject
# If subject matches a number/character combination and contains no spaces,
# the preface will be combined with the doktype.
# If not: preface will contain the whole subject with dots and spaces being
# replaced with underscores
#
def setKeywordsPreface(metadata, doktype)
  if metadata['subject'].match(/^\d+[^+s]+.*/)
    return doktype + metadata['subject']
  else
    subject = metadata['subject']

    # Take care of special characters
    I18n.enforce_available_locales = false
    subject = I18n.transliterate(metadata['subject'])

    # Replace everything else
    subject = subject.gsub(/[^a-zA-Z0-9]+/,'_')
    return subject
  end
end


#
# Function to read the metadata from a given file
# hash readMetadata(string)
#
def readMetadata(pathFile = false) 
  metadata = Hash.new 
  metadata['keywords']    = ''
  metadata['subject']     = ''
  metadata['title']       = ''
  metadata['author']      = ''
  metadata['creator']     = ''
  metadata['createdate']  = ''
  if not File.file?(pathFile)
    puts "Cannot access file #{pathFile}. Abort"
    abort
  end

  # Fetch the Metada with the help of exiftools (unless something better is
  # found
  metaStrings = `exiftool '#{pathFile}' | egrep -i '^Creator\s+\:|^Author|Create Date|Subject|Keywords|Title'`

  # Time to cherrypick the available data
  entries = metaStrings.split("\n")
  entries.each do |entry|
    values = entry.split(" : ")
    values[0].match(/Creator/) and metadata['creator'] == '' ? metadata['creator'] = values[1]: metadata['creator'] = ''
    values[0].match(/Author/) and metadata['author'] == '' ? metadata['author'] = values[1]: metadata['author'] = ''
    values[0].match(/Create Date/) and metadata['createdate'] == '' ? metadata['createdate'] = values[1]: metadata['createdate'] = ''
    values[0].match(/Subject/) and metadata['subject'] == '' ? metadata['subject'] = values[1]: metadata['subject'] = ''
    values[0].match(/Keywords/) and metadata['keywords'] == '' ? metadata['keywords'] = values[1]: metadata['keywords'] =''
    values[0].match(/Title/) and metadata['title'] == '' ? metadata['title'] = values[1]: metadata['title'] =''
  end
  return metadata
end


#
# Read user input
#
def readUserInput(textstring = 'Enter value: ')
  return ask textstring
end


#
# Identify a date
# Function takes a string and tries to identify a date in there.
# returns false if no date could be identified
# otherwise the date is returned in the format as
#
#   YYYY:MM:DD HH:mm:ss
#
# For missing time values zero is assumed
#
def identifyDate(datestring)
  identifiedDate = ''
  year    = '[1-2][90][0-9][0-9]'
  month   = '0[1-9]|10|11|12'
  day     = '[1-9]|0[1-9]|1[0-9]|2[0-9]|3[0-1]'
  hour    = '[0-1][0-9]|2[0-3]|[1-9]'
  minute  = '[0-5][0-9]'
  second  = '[0-5][0-9]'
  case datestring
  when /^(#{year})(#{month})(#{day})$/
    identifiedDate =  $1 + ':' + $2 + ':' + $3 + ' 00:00:00'
  when /^(#{year})(#{month})(#{day})(#{hour})(#{minute})(#{second})$/
    identifiedDate =  $1 + ':' + $2 + ':' + $3 + ' ' + $4 + ':' + $5 + ':' + $6
  when /^(#{year})[\:|\.|\-](#{month})[\:|\.|\-](#{day})\s(#{hour})[\:](#{minute})[\:](#{second})$/
    identifiedDate =  $1 + ':' + $2 + ':' + $3 + ' ' + $4 + ':' + $5 + ':' + $6
  when /^(#{year})[\:|\.|\-](#{month})[\:|\.|\-](#{day})$/
    day   = "%02d" % $3
    month = "%02d" % $2
    identifiedDate =  $1 + ':' + month + ':' + day + ' 00:00:00'
  else
    identifiedDate = false
  end
  return identifiedDate
end
