#
# Thor command 'rename'
#
require_relative '../string_extend'

filename            = ENV.fetch('PDFMD_FILENAME')
opt_allkeywords     = ENV.fetch('PDFMD_ALLKEYWORDS')
outputdir           = ENV.fetch('PDFMD_OUTPUTDIR') == 'false' ? false : ENV.fetch('PDFMD_OUTPUTDIR')
dryrun              = ENV.fetch('PDFMD_DRYRUN') == 'false' ? false : true
opt_numberKeywords  = ENV.fetch('PDFMD_NUMBERKEYWORDS')
opt_copy            = ENV.fetch('PDFMD_COPY')
opt_log             = ENV.fetch('PDFMD_LOG')
opt_logfile         = ENV.fetch('PDFMD_LOGFILE')
hieraDefaults       = queryHiera('pdfmd::config')

if opt_log == 'false'
  logenable = false
elsif opt_log == 'true'
  logenable = true
elsif opt_log.blank? and
  !hieraDefaults.nil? and
  !hieraDefaults['rename'].nil? and
  !hieraDefaults['rename']['log'].nil? and
   hieraDefaults['rename']['log'] == true
  logenable = true
else
  logenable = true
end

if logenable

  if opt_logfile.blank? and
    (
     !hieraDefaults.nil? and
     hieraDefaults['rename'].nil? and 
     (hieraDefaults['rename']['logfile'].nil? or
     hieraDefaults['rename']['logfile'].blank?))

    logfile = Dir.pwd.chomp('/') + '/' + File.basename(ENV['PDFMD'], '.*') + '.log'

  elsif not opt_logfile.blank?

    if File.directory? opt_logfile
      abort('Logfilepath is a directory. Abort.')
      exit 1
    end

    logfile = opt_logfile

  elsif opt_logfile.blank? and
    !hieraDefaults.nil? and
    !hieraDefaults['rename'].nil? and
    !hieraDefaults['rename']['logfile'].nil? and
    not hieraDefaults['rename']['logfile'].blank?

    logfile = hieraDefaults['rename']['logfile']

  else

    logfile = Dir.pwd.chomp('/') + '/' + File.basename(ENV['PDFMD'], '.*') + '.log'

  end

  $logger = Logger.new(logfile)

end

metadata = readMetadata(filename).each do |key,value|

  # Check if the metadata is complete
  if key.match(/author|subject|createdate|title/) and value.empty?
    puts 'Missing value for ' + key
    puts 'Abort'
    exit 1
  end

end


# Determine the status of allkeywords
# Default value is false
if opt_allkeywords == 'true'
  opt_allkeywords = true
elsif opt_allkeywords.blank? and 
  !hieraDefaults.nil? and
  !hieraDefaults['rename'].nil? and
  not hieraDefaults['rename']['allkeywords'].nil?

  opt_allkeywords = hieraDefaults['rename']['allkeywords']

elsif opt_allkeywords == 'false' or
  opt_allkeywords.blank?

  opt_allkeywords = false

end

#
# Determine the number of keywords
# Default value is 3
if opt_numberKeywords.blank? and
  !hieraDefaults.nil? and
  !hieraDefaults['rename'].nil? and
  !hieraDefaults['rename']['keywords'].nil?

  opt_numberKeywords = hieraDefaults['rename']['keywords']

elsif opt_numberKeywords.to_i.is_a? Integer and
  opt_numberKeywords.to_i > 0

  opt_numberKeywords = opt_numberKeywords.to_i

else

  opt_numberKeywords = 3

end

#
# Determine the status of the copy parameter
if opt_copy.blank? and
  !hieraDefaults.nil? and
  !hieraDefaults['rename'].nil? and
  !hieraDefaults['rename']['copy'].nil?

  opt_copy = hieraDefaults['rename']['copy']

elsif opt_copy == 'true'

  opt_copy = true

else

  opt_copy = false

end

# Use a default set for the keywords or (if provided) the keywords from hiera
# The default set is only in english
if !hieraDefaults.nil? and
  !hieraDefaults['rename'].nil? and 
  !hieraDefaults['rename']['keys'].nil? and
  hieraDefaults['rename']['keys'] != ''

  keymappings = hieraDefaults['rename']['keys']

else
  keymappings = {
    'cno' => ['Customer','Customernumber'],
    'con' => ['Contract'],
    'inf' => ['Information'],
    'inv' => ['Invoice', 'Invoicenumber'],
    'man' => ['Manual'],
    'off' => ['Offer', 'Offernumber'],
    'ord' => ['Order', 'Ordernumber'],
    'rec' => ['Receipt', 'Receiptnumber'],
    'tic' => ['Ticket'],
    }
end


date   = metadata['createdate'].gsub(/\ \d{2}\:\d{2}\:\d{2}.*$/,'').gsub(/\:/,'')
author = metadata['author'].gsub(/\./,'_').gsub(/\&/,'').gsub(/\-/,'').gsub(/\s/,'_').gsub(/\,/,'_').gsub(/\_\_/,'_')
I18n.enforce_available_locales = false
author = I18n.transliterate(author) # Normalising

keywords_preface = ''
# Determine the document type from the title.

# Default docment type
if !hieraDefaults.nil? and
  !hieraDefaults['rename'].nil? and
  !hieraDefaults['rename']['defaultdoctype'].nil? and
  hieraDefaults['rename']['defaultdoctype'].empty?

  doktype = hieraDefaults['rename']['defaultdoctype']
else
  doktype = 'doc'
end


## Iterate through the keymappings and try to find a matching doktype
keymappings.each do |key,value|
  value.kind_of?(String) ? value = value.split : ''
  value.each do |keyword|
    metadata['title'].match(/#{keyword}/i) ? doktype = key : ''
  end
end

# Set the preface from the doktype
# This must be added to the beginning of the hash when generating
# the filename so it will come first after the doktype
keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))

if not metadata['keywords'].empty? 
  keywords = ''
  #keywords_preface == '' ? keywords = '' : keywords = keywords_preface
  keywordsarray    = metadata['keywords'].split(',')

  #
  # Sort array
  # and replace key-strings with the abbreviations
  #   in combination with the titel information for the filename
  # BTW: When the value is identical with the title, then it should be 
  # the first keyword IMHO. TODO
  keywordssorted = Array.new
  keywordsarray.each_with_index do |value,index|
    value = value.lstrip.chomp

   # Replace strings for the filename with abbreviations 
   keymappings.each do |abbreviation,keyvaluesarray|
     keyvaluesarray.kind_of?(String) ? keyvaluesarray = keyvaluesarray.split : ''
     keyvaluesarray.each do |keystring|
       value = value.gsub(/#{keystring.lstrip.chomp} /i, abbreviation.to_s)
     end
   end 
    
    # Remove special characters from string
    value = value.gsub(/\s|\/|\-|\./,'_')

    keywordsarray[index] = value

    # If the current values matches some of the replacement-abbreviations,
    # put the keyword on the top of the array to be listed first later on 
    # in the filename
    if value.match(/^#{keymappings.keys.join('|')} /i)
      keywordssorted.insert(0, value)
    else
      keywordssorted.push(value)
    end

  end

  # Insert the document preface in the beginning when it's available
  if not keywords_preface.empty?
    keywordssorted.insert(0, keywords_preface) 
  end

  # all keywords as a string 
  if not opt_allkeywords
    keywords = keywordssorted.values_at(*(0..opt_numberKeywords-1)).join('-')
  else
    keywords = keywordssorted.join('-')
  end

  # Normalise the keywords as well
  I18n.enforce_available_locales = false
  keywords = I18n.transliterate(keywords)

else

  # There are no keywords.
  # we are using the title and the subject
  keywords_preface != '' ? keywords = keywords_preface : ''

end

extension   = 'pdf'
if keywords != nil and keywords[0] != '-'
  keywords = '-' + keywords
end
newFilename = date + '-' +
  author + '-' +
  doktype +
  keywords + '.' + 
  extension

# Output directory checks
if outputdir 

  if not File.exist?(outputdir)
    puts "Error: output dir '#{outputdir}' not found. Abort."
    exit 1
  end

else

  # Try to get the outputdir from hiera
  outputdir = (!hieraDefaults.nil? and !hieraDefaults['rename'].nil? and !hieraDefaults['rename']['outputdir'].nil?) ? hieraDefaults['rename']['outputdir'] : File.dirname(filename)

end

if not dryrun and filename != newFilename.downcase

  logenable ? $logger.info(filename + ' => ' + outputdir + '/' + newFilename.downcase): ''

  # Copy of me the file to the new name
  command = opt_copy ? 'cp' : 'mv'
  `#{command} -v '#{filename}' '#{outputdir}/#{newFilename.downcase}'`

else

  logenable ? $logger.info('Dryrun: ' + filename + ' => ' + outputdir + '/' + newFilename.downcase): ''

end
