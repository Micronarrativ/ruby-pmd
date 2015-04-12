#
# Thor command 'rename'
#
# TODO: align keyword abbreviations for all languages
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

if (opt_log.blank? and not hieraDefaults['rename'].nil? and not hieraDefaults['rename']['log'].nil? and hieraDefaults['rename']['log'] == true) or
  opt_log == 'false' or
  opt_log.blank? 

  logenable = false

else

  logenable = true

end

if logenable

  if opt_logfile.blank? and
    ( hieraDefaults['rename']['logfilepath'].nil? or
     hieraDefaults['rename']['logfilepath'].blank? or
     hieraDefaults['rename'].nil? )

    logfile = Dir.pwd.chomp('/') + '/' + File.basename(ENV['PDFMD'], '.*') + '.log'

  elsif not opt_logfile.blank?

    if File.directory? opt_logfile
      abort('Logfilepath is a directory. Abort.')
      exit 1
    end

    logfile = opt_logfile

  elsif opt_logfile.blank? and
    not hieraDefaults['rename']['logfilepath'].blank?

    logfile = hieraDefaults['rename']['logfilepath']

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
  not hieraDefaults['rename'].nil? and
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
  not hieraDefaults['rename'].nil? and
  not hieraDefaults['rename']['keywords'].nil?

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
  not hieraDefaults['rename'].nil? and
  not hieraDefaults['rename']['copy'].nil?

  opt_copy = hieraDefaults['rename']['copy']

elsif opt_copy == 'true'

  opt_copy = true

else

  opt_copy = false

end


date   = metadata['createdate'].gsub(/\ \d{2}\:\d{2}\:\d{2}.*$/,'').gsub(/\:/,'')
author = metadata['author'].gsub(/\./,'_').gsub(/\&/,'').gsub(/\-/,'').gsub(/\s/,'_').gsub(/\,/,'_').gsub(/\_\_/,'_')
I18n.enforce_available_locales = false
author = I18n.transliterate(author) # Normalising

keywords_preface = ''
# This statement can probably be optimised
case metadata['title']
when /(Tilbudt|Angebot|Offer)/i
  doktype = 'til'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /Orderbekreftelse/i
  doktype = 'odb'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /faktura/i
  doktype = 'fak'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /invoice/i
  doktype = 'inv'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /rechnung/i
  doktype = 'rec'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /order/i
  doktype = 'ord'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /bestilling/i
  doktype = 'bes'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /(kontrakt|avtale|vertrag|contract)/i
  doktype = 'avt'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /kvittering/i
  doktype = 'kvi'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /manual/i
  doktype = 'man'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /(billett|ticket)/i
  doktype = 'bil'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /(informasjon|information)/i
  doktype = 'inf'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
else
  doktype = 'dok'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
end
if not metadata['keywords'].empty? 
  keywords_preface == '' ? keywords = '' : keywords = keywords_preface
  keywordsarray    = metadata['keywords'].split(',')

  #
  # Sort array
  #
  keywordssorted = Array.new
  keywordsarray.each_with_index do |value,index|
    value = value.lstrip.chomp
    value = value.gsub(/(Faktura|Rechnungs)(nummer)? /i,'fak')
    value = value.gsub(/(Kunde)(n)?(nummer)? /i,'kdn')
    value = value.gsub(/(Kunde)(n)?(nummer)?-/i,'kdn')
    value = value.gsub(/(Ordre|Bestellung)(s?nummer)? /i,'ord')
    value = value.gsub(/(Kvittering|Quittung)(snummer)? /i,'kvi')
    value = value.gsub(/\s/,'_')
    value = value.gsub(/\//,'_')
    keywordsarray[index] = value
    if value.match(/^(fak|kdn|ord|kvi)/)
      keywordssorted.insert(0, value)
    else
      keywordssorted.push(value)
    end
  end

  counter = 0
  keywordssorted.each_with_index do |value,index|

    # Exit condition limits the number of keywords used in the filename
    # unless all keywords shall be added
    if not opt_allkeywords
      counter >= opt_numberKeywords-1 ? break : counter = counter + 1
    end
    if value.match(/(kvi|fak|ord|kdn)/i)
      keywords == '' ? keywords = '-' + value : keywords = value + '-' + keywords
    else
      keywords == '' ? keywords = '-' + value : keywords.concat('-' + value)
    end
  end

  # Normalise the keywords as well
  #
  I18n.enforce_available_locales = false
  keywords = I18n.transliterate(keywords)

  # There are no keywords
  # Rare, but it happens
else

  # There are no keywords.
  # we are using the title and the subject
  if keywords_preface != '' 
    keywords = keywords_preface
  end

end
extension   = 'pdf'
if keywords != nil and keywords[0] != '-'
  keywords = '-' + keywords
end
keywords == nil ? keywords = '' : ''
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
  outputdir = (not hieraDefaults['rename'].nil? and not hieraDefaults['rename']['outputdir'].nil?) ? hieraDefaults['rename']['outputdir'] : File.dirname(filename)

end

if not dryrun and filename != newFilename.downcase

  logenable ? $logger.info(filename + ' => ' + outputdir + '/' + newFilename.downcase): ''

  # Copy of me the file to the new name
  command = opt_copy ? 'cp' : 'mv'
  `#{command} -v '#{filename}' '#{outputdir}/#{newFilename.downcase}'`

else

  logenable ? $logger.info('Dryrun: ' + filename + ' => ' + outputdir + '/' + newFilename.downcase): ''

end
