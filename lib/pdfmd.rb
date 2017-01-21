# == File: pdfmd.rb
#
# Class for PDF document and meta tag management
#
require_relative './pdfmd/pdfmdmethods.rb'
class Pdfmd

  require "i18n"
  require 'pathname'
  require 'fileutils'
  require "highline/import"

  # Include general method for Pdfmd
  include Pdfmdmethods

  attr_accessor :filename, :logstatus, :logfile, :hieradata, :logfile

  require_relative 'pdfmd/pdfmdshow.rb'
  require_relative 'pdfmd/pdfmdconfig.rb'
  require_relative 'pdfmd/pdfmdedit.rb'
  require_relative 'pdfmd/pdfmdrename.rb'
  require_relative 'pdfmd/pdfmdsort.rb'
  require_relative 'pdfmd/string_extend.rb'
  require_relative 'pdfmd/pdfmdclean.rb'
  require_relative 'pdfmd/pdfmddb.rb'
  require 'logger'

  DEFAULT_TAGS        = ['createdate', 'author', 'title', 'subject', 'keywords']

  # Default document password
  @@documentPassword  = ''

  # Document metadata, read from the document
  @@metadata          = Hash.new

  # Hiera configuration data
  @@hieradata          = Pdfmdmethods.queryHiera('pdfmd::config')

  def self.hieradata
    @@hieradata
  end

  # Field seperator for edit tags
  @@edit_separator = '='

  @@logfile = 'test'

  def initialize

    # Default Logfile location and logging enabled
    if !@logfile or @logfile.empty?
      @logfile = Dir.pwd.chomp('/') + '/.pdfmd.log'
    end
    @log      = true

    # Defining the loglevel
    @loglevel = 'info'
    Pdfmdmethods.log('debug','---')

  end

  # Sets the file to work on.
  def set_file(filename)
    @filename  = filename
    if ! filename.empty?
      read_metatags(@filename)
    end
  end

  #
  # Make Metadata available to the outside
  def metadata
    @@metadata
  end

  #
  # Logging stuff
  # def log(status = 'info', message)

  #   # Setting the loglevel
  #   case @loglevel
  #   when /info/i
  #     level = 'Logger::INFO'
  #   when /warn/i
  #     level = 'Logger::WARN'
  #   when /error/i
  #     level = 'Logger::ERROR'
  #   when /debug/i
  #     level = 'Logger::DEBUG'
  #   else
  #     level = 'Logger::INFO'
  #   end
  #   logger = Logger.new(@logfile)
  #   logger.level = eval level
  #   logger.send(status, message)
  #   logger.close

  # end

  #
  # Check all or certain metatags
  # If there is no content for a tag, return false
  def check_metatags(metatags = [])

    if metatags.is_a?(String)
      metatags = metatags.split
    elsif !metatags.is_a?(Array)
      Pdfmdmethods.log('error', 'Array or string parameter expected for parameter of check_metatags.')
      exit 1
    end

    metatags.each do |value|
      if @@metadata[value].to_s.empty?
        false
      end
    end

  end

  # Read metatags from @metadata froma file into
  # @@metadata
  def read_metatags(filename)

    # Setup the metatags
    commandparameter = '-Warning'
    DEFAULT_TAGS.each do |key|
      @@metadata[key] = ''
      commandparameter = commandparameter + " -#{key}"
    end

    if not File.file?(filename)
      Pdfmdmethods.log('error', "Cannot access file '#{filename}'.")
      puts "Cannot access file for reading metatags '#{filename}'. Abort"
      abort
    end

    begin
    metastrings = `exiftool #{commandparameter} '#{filename}'`.split("\n") 
    rescue
      puts "Error with document '#{filename}'."
      metastrings = Array.new
    end

    # Assume an error (to enter the loop)
    metaPasswordError = true

    # Repeat password request to user until a valid password has been provided.
    # This loop can surely be made prettier.
    while metaPasswordError

      metaPasswordError = false
      metastrings.each do |metatag|
        if metatag.match(/warning.*password protected/i)
          Pdfmdmethods.log('info',"File '#{filename}' is password protected.")
          metaPasswordError = true
        end
      end

      # Leave this loop if there is no error in accessing the document
      if !metaPasswordError
        break
      end

      triedHieraPassword ||= false
      triedManualPassword ||= 0
      # Try a hiera password first, request otherwise from the user
      if documentPassword = self.determineValidSetting(nil, 'default:password') and
        !triedHieraPassword

        Pdfmdmethods.log('debug','Using default password from hiera.')
        @@documentPassword = documentPassword
        triedHieraPassword = true

      else

        # Message output if default password was not working
        if triedHieraPassword and triedManualPassword == 0
          Pdfmdmethods.log('warn','Default password from hiera is invalid.')
        end

        # Exit loop if there were more than three manual password inputs
        if triedManualPassword == 3
          Pdfmdmethods.log('error',"More than three password attempts on file '#{filename}'. Abort.")
          exit 1
        end

        # Request password from user
        Pdfmdmethods.log('info', 'Requesting password from user.')
        @@documentPassword = readUserInput('Document password : ').chomp
        triedManualPassword = 1 + triedManualPassword
        puts ''
      end

      metastrings = `exiftool -password '#{@@documentPassword}' #{commandparameter} '#{filename}'`.split("\n")

    end


    # NB: Maybe the output format should be changed here to catch keywords
    # matching the split string ('   : '). Exiftool has a format output option as well.
    Pdfmdmethods.log('debug', "Reading metadata from file '#{filename}'.")
    metastrings.each do |key|
      value = key.split('    : ')
      metatag = value[0].downcase.gsub(/ /,'')
      if @@metadata.has_key?( metatag )
        @@metadata[ metatag ] = value[1]
      end
    end

  end

  #
  # Read user input
  def readUserInput(textstring = 'Enter value: ')

    Pdfmdmethods.log('info','Waiting for user input.')
    if textstring.match(/password/i)
      print textstring
      STDIN.noecho(&:gets).chomp + "\n"
    else
      ask textstring
    end

  end

  #
  # Query hiera for settings if available
  # def queryHiera(keyword, facts = 'UNSET')

  #   # Set default facts
  #   facts == 'UNSET' ? facts = "fqdn=#{`hostname`}" : ''

  #   # If Hiera is not found (damn cat, get of my keyboard!), return false,
  #   # otherwise return the hash from Hiera
  #   if !system('which hiera > /dev/null 2>&1')
  #     self.log('warn','Cannot find hiera command in $path.')
  #     puts 'Cannot find "hiera" command in $path.'
  #     return eval('{}')
  #   else
  #     self.log('debug', 'Reading hiera values for pdfmd::config.')
  #     commandreturn = ''
  #     commandreturn = `hiera #{keyword} #{facts} 2>/dev/null`

  #     if $?.exitstatus == 1
  #       self.log('warn', 'Could not retrieve configuration from with hiera.')
  #       eval('{}')
  #     else
  #       self.log('debug', 'Could retrieve configuration from hiera.')
  #       eval(commandreturn)
  #     end

  #   end

  # end # End of queryHiera


  #
  # Determine the valid setting
  # 1. Priority: manual setting
  # 2. Priority: Hiera setting
  #
  # If there is no manual setting, the value of 'manualSetting'
  #   should be set to 'nil'
  #
  def determineValidSetting(manualSetting,key)

  #  if !@hieradata.nil?
  #     hieraKey    = '@hieradata'
  #     hieraValue  = ''

  #     key.split(':').each do |keyname|

  #       hieraKeyCheck = eval(hieraKey)
  #       if !hieraKeyCheck.nil? and hieraKeyCheck.has_key?(keyname)
  #         hieraKey = hieraKey + "['#{keyname}']"
  #       else
  #         # Key has not been found
  #         hieraKey = ''
  #         break
  #       end
  #     end

  #     hieraValue = eval(hieraKey)
  #  else
  #    #hieraValue = nil
  #  end

  #   if !manualSetting.nil?
  #     Pdfmdmethods.log('debug', "Chosing manual setting '#{key} = #{manualSetting}'.")
  #     manualSetting
  #   elsif !hieraValue.nil? or
  #     !hieraValue == ''

  #     self.log('debug', "Chosing hiera setting '#{key} = #{hieraValue}'.")
  #     hieraValue

  #   else
  #     Pdfmdmethods.log('debug', "No setting chosen for '#{key}' in hiera.")
  #     false
  #   end

  end

end # End of Class
