#
# Thor command 'rename'
#
# TODO: Define outputdir from Hiera
# TODO: Add option for copy when renaming
# TODO: Add option to create outputdir if not existing
# TODO: Define option to create outputdir via Hiera
#
filename        = ENV.fetch('PDFMD_FILENAME')
allkeywords     = ENV.fetch('PDFMD_ALLKEYWORDS')
outputdir       = ENV.fetch('PDFMD_OUTPUTDIR') == 'false' ? false : ENV.fetch('PDFMD_OUTPUTDIR')
dryrun          = ENV.fetch('PDFMD_DRYRUN') == 'false' ? false : true
numberKeywords  = ENV.fetch('PDFMD_NUMBERKEYWORDS').to_i

metadata = readMetadata(filename).each do |key,value|

  # Check if the metadata is complete
  if key.match(/author|subject|createdate|title/) and value.empty?
    puts 'Missing value for ' + key
    puts 'Abort'
    exit 1
  end

end

date   = metadata['createdate'].gsub(/\ \d{2}\:\d{2}\:\d{2}.*$/,'').gsub(/\:/,'')
author = metadata['author'].gsub(/\./,'_').gsub(/\-/,'').gsub(/\s/,'_')
I18n.enforce_available_locales = false
author = I18n.transliterate(author) # Normalising

keywords_preface = ''
# This statement can probably be optimised
case metadata['title']
when /(Tilbudt|Angebot)/i
  doktype = 'til'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /Orderbekrefelse/i
  doktype = 'odb'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /faktura/i
  doktype = 'fak'
  keywords_preface = setKeywordsPreface(metadata,doktype.gsub(/\-/,''))
when /order/i
  doktype = 'ord'
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
    if not allkeywords.empty?
      counter > numberKeywords-1 ? break : counter = counter + 1
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
  # Output to Inputdir
  outputdir = File.dirname(filename)
end

if not dryrun and filename != newFilename.downcase
  `mv -v '#{filename}' '#{outputdir}/#{newFilename.downcase}'`
else
  puts filename + "\n   => " + newFilename.downcase
end
