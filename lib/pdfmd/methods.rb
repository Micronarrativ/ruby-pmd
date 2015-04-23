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
# Besides the fields from the exif-fields two additional fields can be set:
#
# error: is being set with a string in case exiftools returns a warning field
# password: is being set when a password has been necessary to access the
#   protected fields.
#
def readMetadata(pathFile = false) 
  metadata = Hash.new 
  metadata['keywords']    = ''
  metadata['subject']     = ''
  metadata['title']       = ''
  metadata['author']      = ''
  metadata['creator']     = ''
  metadata['createdate']  = ''
  metadata['password']    = ''
  metadata['error']       = ''
  if not File.file?(pathFile)
    puts "Cannot access file #{pathFile}. Abort"
    abort
  end

  # Fetch the Metada with the help of exiftools (unless something better is
  # found
  tags        = '^Creator\s+\:|^Author|Create Date|Subject|Keywords|Title|^Warning'
  metaStrings = `exiftool '#{pathFile}' | egrep -i '#{tags}'`

  # Create an array of all data
  entries = metaStrings.split("\n")

  # If this matches, the file is password protected.
  # Grep the password from hiera or from the user
  if entries.index{ |x| x.match(/Document is password protected/) } 

    # Grep data from hiera
    hieraDefaults = queryHiera('pdfmd::config')

    # Use Hiera default PW if possible
    if not hieraDefaults['default'].nil? and
      not hieraDefaults['default']['password'].nil? and
      not hieraDefaults['default']['password'] == ''

      documentPassword = hieraDefaults['default']['password']

    # Ask the user for a password
    else

      documentPassword = readUserInput('Please provide user password: ')

    end

    # Try to get the metadata again, this time with the password
    metaStrings = `exiftool -password '#{documentPassword}' '#{pathFile}' | egrep -i '#{tags}'`
    # Add the password to the metadata and make it available to the other procedures
    metadata['password'] = documentPassword

    # Create an array of all entries
    entries = metaStrings.split("\n")

  end

  entries.each do |entry|
    values = entry.split(" : ")
    values[0].match(/Creator/) and metadata['creator'] == '' ? metadata['creator'] = values[1]: metadata['creator'] = ''
    values[0].match(/Author/) and metadata['author'] == '' ? metadata['author'] = values[1]: metadata['author'] = ''
    values[0].match(/Create Date/) and metadata['createdate'] == '' ? metadata['createdate'] = values[1]: metadata['createdate'] = ''
    values[0].match(/Subject/) and metadata['subject'] == '' ? metadata['subject'] = values[1]: metadata['subject'] = ''
    values[0].match(/Keywords/) and metadata['keywords'] == '' ? metadata['keywords'] = values[1]: metadata['keywords'] =''
    values[0].match(/Title/) and metadata['title'] == '' ? metadata['title'] = values[1]: metadata['title'] =''

    if values[0].match(/Warning/) and values[1].match(/Document is password protected/)
      puts 'Document is protected'
    end

    # Password is not correct. Abort
    if values[0].match(/Warning/) and values[1].match(/Incorrect password/)
      abort values[1] + '. Abort!'
    end
  end

  return metadata
end


#
# Read user input
#
def readUserInput(textstring = 'Enter value: ')

  # if there is a password mentioned, hide the input
  if textstring.match(/password/i)

    print textstring
    userinput =  STDIN.noecho(&:gets).chomp
    puts ''
    return userinput

  else

    return ask textstring

  end
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
