#
# == File: sort.rb
#
# Actions for the sort command
#
inputDir = ENV.fetch('PDFMD_INPUTDIR')

require_relative('./methods.rb')
require 'fileutils'

opt_destination = ENV.fetch('PDFMD_DESTINATION')
opt_dryrun      = ENV.fetch('PDFMD_DRYRUN') == 'true' ? true : false
opt_copy        = ENV.fetch('PDFMD_COPY')
opt_log         = ENV.fetch('PDFMD_LOG')
opt_interactive = ENV.fetch('PDFMD_INTERACTIVE')

hieraDefaults = queryHiera('pdfmd::config')

copyAction  = opt_copy.empty? ? false : true
if opt_copy.nil? and hieraDefaults['sort']['copy'] == true
  copyAction = true
  puts 'Setting action to copy based on Hiera.'
end

interactiveAction = opt_interactive.empty? ? false : true
if opt_interactive.empty? and hieraDefaults['sort']['interactive'] == true
  interactiveAction = true
  puts 'Setting interactive to true based on Hiera.'
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

logenable = opt_log
logfile   = !hieraDefaults['sort']['logfile'].nil? ? hieraDefaults['sort']['logfile'] : Dir.pwd.chomp('/') + '/' + Pathname.new(__FILE__).basename + '.log'

# Check that logfilepath exists and is writeable
if !File.writable?(logfile)
  puts "Cannot write '#{logfile}. Abort."
  exit 1
end
logenable ? $logger = Logger.new(logfile) : ''

# Input validation
!File.exist?(inputDir) ? abort('Input directory does not exist. Abort.'): ''
File.directory?(inputDir) ? '' : abort('Input is a single file. Not implemented yet. Abort.')
File.file?(destination) ? abort("Output '#{destination}' is an existing file. Cannot create directory with the same name. Abort") : ''
unless File.directory?(destination)
  FileUtils.mkdir_p(destination)
  $logger.info("Destination '#{destination}' has been created.")
end

# Iterate through all files
Dir[inputDir.chomp('/') +  '/*.pdf'].sort.each do |file|

  if interactiveAction
    answer = readUserInput("Process '#{file}' ([y]/n): ")
    answer = answer.empty? ? 'y' : answer 
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
      $logger.info("File '#{file}' => '#{filedestination}'")

      # Move/Copy the file
      if copyAction and not opt_dryrun
        #FileUtils.cp(file, filedestination)
      elsif not opt_dryrun
        #FileUtils.mv(file,filedestination)
      end

    else
      logenable ? $logger.warn("File '#{filedestination}' already exists. Ignoring.") : ''
    end
  else
    logenable ? $logger.warn("Missing tag 'Author' for file '#{file}'. Skipping.") : (puts "Missing tag 'Author' for file '#{file}'. Skipping")
    next
  end
end
