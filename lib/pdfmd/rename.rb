#
# Thor command 'rename'
#
# TODO: Make keywords abbreviations configurable from Hiera
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
# Determine the document type from the title.
# Languages: DE|NO|EN
case metadata['title']
when /Tilbudt/i
  doktype = 'til'
when /Offer/i
  doktype = 'off'
when /Angebot/i
  doktype = 'ang'
when /Orderbekreftelse/i
  doktype = 'odb'
when /faktura/i
  doktype = 'fak'
when /invoice/i
  doktype = 'inv'
when /rechnung/i
  doktype = 'rec'
when /order/i
  doktype = 'ord'
when /bestilling/i
  doktype = 'bes'
when /(kontrakt|avtale)/i
  doktype = 'avt'
when /vertrag/i
  doktype = 'ver'
when /contract/i
  doktype = 'con'
when /kvittering/i
  doktype = 'kvi'
when /manual/i
  doktype = 'man'
when /billett/i
  doktype = 'bil'
when /ticket/i
  doktype = 'tik'
when /(informasjon|information)/i
  doktype = 'inf'
else
  doktype = 'dok'
end
# Set the preface from the doktype
keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))

if not metadata['keywords'].empty? 
  keywords_preface == '' ? keywords = '' : keywords = keywords_preface
  keywordsarray    = metadata['keywords'].split(',')

  #
  # Sort array
  # and replace key-strings with the abbreviations
  #   in combination with the titel information
  # I need to make this one better and make it configurable from
  #   Hiera. But not right now.
  #
  keywordssorted = Array.new
  keywordsarray.each_with_index do |value,index|
    value = value.lstrip.chomp
    
    # Invoices
    value = value.gsub(/Faktura(nummer)? /i,'fak')
    value = value.gsub(/Rechnung(snummer)? /i, 'rec')
    value = value.gsub(/Invoice(number)? /i, 'inv')

    # Customernumbers
    value = value.gsub(/Kunde(n)?(nummer)? /i,'kdn')
    value = value.gsub(/Customer(number)? /i, 'cno')

    # Ordernumbers
    value = value.gsub(/Bestellung(s?nummer)? /i,'bes')
    value = value.gsub(/(Ordre)(nummer)? /i,'ord')
    value = value.gsub(/Bestilling(snummer)? /i,'bst')

    # Receiptnumbers
    value = value.gsub(/(Kvittering)(snummer)? /i,'kvi')
    value = value.gsub(/Quittung(snummer)? /i,'qui')
    value = value.gsub(/Receipt(number)? /i, 'rpt')

    # Remove special characters from string
    value = value.gsub(/\s|\/|\-|\./,'_')

    keywordsarray[index] = value
    if value.match(/^(fak|rec|inv|cno|kdn|bes|ord|bst|kvi|qui|rpt)/)
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
    if value.match(/^(fak|rec|inv|cno|kdn|bes|ord|bst|kvi|qui|rpt)/)
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
