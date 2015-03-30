#
# == File: sort.rb
#
# Actions for the sort command
#
inputDir = ENV.fetch('PDFMD_INPUTDIR')

require_relative('./methods.rb')
require_relative '../string_extend.rb'
require 'fileutils'

opt_destination = ENV.fetch('PDFMD_DESTINATION')
opt_dryrun      = ENV.fetch('PDFMD_DRYRUN') == 'true' ? true : false
opt_copy        = ENV.fetch('PDFMD_COPY')
opt_log         = ENV.fetch('PDFMD_LOG')
opt_logfilepath = ENV.fetch('PDFMD_LOGFILEPATH')
opt_interactive = ENV.fetch('PDFMD_INTERACTIVE')
hieraDefaults   = queryHiera('pdfmd::config')

# Determin the setting for the copy/move action when sorting
# Use HieraDefaults if nothing has been set.
copyAction  = opt_copy
if copyAction.blank? and hieraDefaults['sort']['copy'] == true
  copyAction = true
elsif copyAction.blank? or copyAction == 'false'
  copyAction = false
end

# Determine the setting for interaction
if opt_interactive.blank? and hieraDefaults['sort']['interactive'] == true
  puts 'Setting interactive from hiera'
  interactiveAction = true
elsif opt_interactive == 'true'
  interactiveAction = true
elsif opt_interactive.blank? or opt_interactive == 'false'
  interactiveAction = false
end

# Fetch alternate destination from hiera if available
destination = opt_destination
if destination.nil? or destination == ''

  hieraHash = queryHiera('pdfmd::config')
  if !hieraHash['sort']['destination'].nil?
    destination = hieraHash['sort']['destination']
  else
    puts 'No information about destination found.'
    puts 'Set parameter -d or configure hiera.'
    puts 'Abort.'
    exit 1
  end
end

# Determine the state of the logging
if (opt_log.blank? and hieraDefaults['sort']['log'] == true) or
  opt_log == 'true'
  logenable = true
elsif opt_log.blank? or opt_log == 'false'
  logenable = false
end

if logenable

  if opt_logfilepath.blank? and 
    ( hieraDefaults['sort']['logfilepath'].nil? or
     hieraDefaults['sort']['logfilepath'].blank? or
     hieraDefaults['sort'].nil? )

    logfile = Dir.pwd.chomp('/') + '/' + File.basename(ENV['PDFMD'], '.*') + '.log'

  elsif not opt_logfilepath.blank?

    if File.directory? opt_logfilepath
      abort('Logfilepath is a directory. Abort.')
      exit 1
    end

    logfile = opt_logfilepath

  elsif opt_logfilepath.blank? and
    not hieraDefaults['sort']['logfilepath'].blank? 

    logfile = hieraDefaults['sort']['logfilepath']

  else

    logfile = Dir.pwd.chomp('/') + '/' + File.basename(ENV['PDFMD'], '.*') + '.log'

  end

  $logger = Logger.new(logfile)
end

# Input validation
!File.exist?(inputDir) ? abort('Input directory does not exist. Abort.'): ''
File.directory?(inputDir) ? '' : abort('Input is a single file. Not implemented yet. Abort.')
File.file?(destination) ? abort("Output '#{destination}' is an existing file. Cannot create directory with the same name. Abort") : ''
unless File.directory?(destination)
  FileUtils.mkdir_p(destination)
  logenable ? $logger.info("Destination '#{destination}' has been created.") : ''
end

# Iterate through all files
Dir[inputDir.chomp('/') +  '/*.pdf'].sort.each do |file|

  if interactiveAction
    answer = readUserInput("Process '#{file}' ([y]/n): ")
    answer = answer.empty? ? 'y' : answer 
    logenable ? $logger.info("Interactive answer for file '#{file}' : #{answer}") : ''
    answer.match(/y/) ? '' : next
  end

  metadata = readMetadata(file)
  if metadata['author'] and not metadata['author'].empty?
    author                          = metadata['author'].gsub(' ','_').gsub('.','_')
    I18n.enforce_available_locales  = false # Serialize special characters
    author                          = I18n.transliterate(author).downcase
    folderdestination               = destination.chomp('/') + '/' + author

    unless File.directory?(folderdestination)
      FileUtils.mkdir_p(folderdestination)
      logenable ? $logger.info("Folder '#{folderdestination}' has been created."): ''
    end

    filedestination                 = destination.chomp('/') + '/' + author + '/' + Pathname.new(file).basename.to_s


    # Final check before touching the filesystem
    if not File.exist?(filedestination)

      # Move/Copy the file
      if copyAction 
        opt_dryrun ? '' : FileUtils.cp(file, filedestination)
        logenable ? $logger.info("File copied '#{file}' => '#{filedestination}'") : ''
      else
        opt_dryrun ? '' : FileUtils.mv(file,filedestination)
        logenable ? $logger.info("File moved '#{file}' => '#{filedestination}'") : ''
      end

    else
      logenable ? $logger.warn("File '#{filedestination}' already exists. Ignoring.") : ''
    end
  else
    logenable ? $logger.warn("Missing tag 'Author' for file '#{file}'. Skipping.") : (puts "Missing tag 'Author' for file '#{file}'. Skipping")
    next
  end
end
