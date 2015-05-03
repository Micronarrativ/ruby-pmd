#
# Thor command 'edit' for changing the common
# ExifTags within the PDF file
# TODO: backup file/path into hiera and options
#

require_relative '../string_extend'

filename    = ENV.fetch('PDFMD_FILENAME')
optTag      = ENV['PDFMD_TAG'] || nil
opt_rename  = ENV['PDFMD_RENAME']
pdfmd       = ENV['PDFMD']
opt_log     = ENV['PDFMD_LOG']
opt_logfile = ENV['PDFMD_LOGFILE']
hieraDefaults = queryHiera('pdfmd::config')

# Rename or not
if opt_rename == 'true'
  opt_rename = true
elsif opt_rename == 'false'
  opt_rename = false
elsif (!hieraDefaults.nil? and
  !hieraDefaults['edit'].nil? and
  ! hieraDefaults['edit']['rename'].nil? and
  hieraDefaults['edit']['rename'] == true)
  opt_rename = true
else
  opt_rename = false
end

# Define logging state
if (hieraDefaults.nil? or
  hieraDefaults['edit'].nil? or
  hieraDefaults['edit']['log'].nil? or
  !hieraDefaults['edit']['log'] == true ) and
  (opt_log == 'false' or opt_log.blank?)

  logenable = false
  
else

  logenable = true

end

# If logging is enabled, set parameters and create the obkject
if logenable

  if opt_logfile.nil?  and
    ( hieraDefaults['edit'].nil? or
    hieraDefaults['edit']['logfile'].nil? or
    hieraDefaults['edit']['logfile'].blank? ) 

    logfile = Dir.pwd.chomp('/') + '/' + File.basename(ENV['PDFMD'], '.*') + '.log'

  elsif not opt_logfile.nil? and not opt_logfile.blank?

    if File.directory? opt_logfile
      abort('Logfile path is a directory. Abort.')
      exit 1
    end

    logfile = opt_logfile

  elsif (opt_logfile.nil? or opt_logfile.blank?) and
    not hieraDefaults['edit']['logfile'].blank?

    logfile = hieraDefaults['edit']['logfile']

  else

    logfile = Dir.pwd.chomp('/') + '/' + File.basename(ENV['PDFMD'], '.*') + '.log'

  end

  $logger = Logger.new(logfile)

end

metadata = readMetadata(filename)

# Set the password for the exiftool if available
if metadata['password'].size > 0
  logenable ? $logger.info("#{filename}: Using PDF password to edit metadata.") : ''
  exifPdfPassword = "-password '#{metadata['password']}'"
else
  exifPdfPassword = ''
end

if optTag == 'all'
  tags = ['author','title','subject','createdate','keywords']
else
  tags = optTag.split(',')
end

tags.each do |currentTag|

  # If the tags contain an '=', set the value for the tag
  # automatically. Otherwise enter interactive mode.
  if currentTag.match(/\=/)

    tag, value = currentTag.split('=')

    # Include Date identifier
    if tag.downcase == 'createdate'
      value = identifyDate(value)
    end

    logenable ? $logger.info("#{filename}: Setting value for tag '#{tag.downcase}': '#{value}'") : ''

    # Running the exiftool with optional PDF password parameter on the original file
    `exiftool #{exifPdfPassword} -#{tag.downcase}='#{value}' -overwrite_original '#{filename}'`

  else

    # Change the tag to something we can use here
    puts "Current value: '#{metadata[currentTag.downcase]}'"
    answer     = readUserInput("Enter new value for #{currentTag} :")
    answerCopy = answer
    if currentTag.downcase == 'createdate'
      while not answer = identifyDate(answer)
        logenable ? $logger.warn("${filename}: Invalid date provided: '#{answerCopy}'.") : ''
        logenable ? $logger.info("${filename}: Asking for new user provided date.") : ''
        puts 'Invalid date format.'
        answer = readUserInput("Enter new value for #{currentTag} :")
      end
    end
    puts "Changing value for #{currentTag}: '#{metadata[currentTag]}' => #{answer}"
    logenable ? $logger.info("#{filename}: Setting value for tag '#{currentTag.downcase}': '#{answer}'") : ''

    # Running the exiftool with optional PDF password parameter on the original file
    `exiftool #{exifPdfPassword} -#{currentTag.downcase}='#{answer}' -overwrite_original '#{filename}'`
  
  end # If interactive/batch mode
end

#
# If required, run the renaming task afterwards
# This is not pretty, but seems to be the only way to do this in THOR
#
if opt_rename
  logenable ? $logger.info("#{filename}: Trigger file renaming.") : ''
  `#{pdfmd} rename '#{filename}'`
end
