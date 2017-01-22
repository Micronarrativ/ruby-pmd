# == Module: pdfmdmethods
# 
# Method to extend functionalities
module Pdfmdmethods

  # 
  # Determine the valid setting
  # 1. Priority: manual setting
  # 2. Priority: Hiera setting
  #
  # If there is no manual setting, the value of 'manualSetting'
  #   should be set to 'nil'
  #
  def Pdfmdmethods.determineValidSetting(manualSetting,key, hieradata={})

    if !hieradata.nil? 
      hieraKey    = 'hieradata'
      hieraValue  = ''

      key.split(':').each do |keyname|

        hieraKeyCheck = eval(hieraKey)
        if !hieraKeyCheck.nil? and hieraKeyCheck.has_key?(keyname)
          hieraKey = hieraKey + "['#{keyname}']"
        else
          # Key has not been found
          hieraKey = ''
          break
        end 
      end

      hieraValue = eval(hieraKey)

    else
      hieraValue = nil
    end

    if !manualSetting.nil?
      Pdfmdmethods.log('debug', "Chosing manual setting '#{key} = #{manualSetting}'.")

      # if manualSetting is date, the actual field meant is "'create date'", not 'date'.
      key = key.gsub('date:', 'createdate:')

      manualSetting
    elsif !hieraValue.nil? or
      !hieraValue == ''

      self.log('debug', "Chosing hiera setting '#{key} = #{hieraValue}'.")
      hieraValue

    else
      self.log('debug', "No setting chosen for '#{key}' in hiera.")
      false 
    end

  end


  #
  # Logging stuff
  def Pdfmdmethods.log(status = 'info', message)

    # Setting the loglevel
    case @loglevel
    when /info/i
      level = 'Logger::INFO'
    when /warn/i
      level = 'Logger::WARN'
    when /error/i
      level = 'Logger::ERROR'
    when /debug/i
      level = 'Logger::DEBUG'
    else
      level = 'Logger::INFO'
    end
    logger = Logger.new(@logfile)
    logger.level = eval level
    logger.send(status, message)
    logger.close

  end



  #
  # Query hiera for settings if available
  def Pdfmdmethods.queryHiera(keyword, facts = 'UNSET')

    pathHieraConfig = [
      '/etc/hiera.yaml',
      '/etc/puppet/hiera.yaml',
      '/etc/puppetlabs/puppet/hiera.yaml',
    ]
    hieraConfig = ''
    pathHieraConfig.each do |path|
      if File.exist? path
        hieraConfig = path
        break
      end
    end

    # Set default facts
    facts == 'UNSET' ? facts = "fqdn=#{`hostname`}".chomp : ''.chomp

    # If Hiera is not found (damn cat, get of my keyboard!), return false,
    # otherwise return the hash from Hiera
    if !system('which hiera > /dev/null 2>&1')
      self.log('warn','Cannot find hiera command in $path.')
      puts 'Cannot find "hiera" command in $path.'
      return eval('{}')
    else

      self.log('debug', 'Reading hiera values for pdfmd::config.')
      commandreturn = ''
      commandreturn = `hiera -c #{hieraConfig} #{keyword} #{facts} 2>/dev/null`

      if $?.exitstatus == 1
        self.log('warn', 'Could not retrieve configuration from with hiera.')
        eval('{}')
      else
        self.log('debug', 'Could retrieve configuration from hiera.')
        eval(commandreturn)
      end

    end

  end # End of queryHiera

end

#
# Initializing or removing the bash_completion file
def Pdfmdmethods.init_bashcompletion(name, version, remove = false)

  # Find the current local path where the original bash completion file might be hiding.
  paths = [
    "#{File.dirname(File.expand_path($0))}/../lib",
    "#{Gem.dir}/gems/#{name}-#{version}/lib",
  ]
  bash_completion_destination        = '/etc/bash_completion.d/pdfmd.bash'
  bash_completion_destination_backup = bash_completion_destination + '.backup'

  paths.each do |value|
    bash_completion_source = value + '/' + name + '/pdfmd.bash'
    if File.exists?(bash_completion_source)

      if !remove

        # Create a backup file when a file is found
        if File.exists?(bash_completion_destination)
          puts 'Existing file found.Taking backup.'
          `sudo cp #{bash_completion_destination} #{bash_completion_destination_backup}`
        end
        puts 'Installing ' + bash_completion_destination
        `sudo cp #{bash_completion_source} #{bash_completion_destination}`
      else

        if File.exists?(bash_completion_destination)
          puts 'Removing ' + bash_completion_destination
          `sudo rm #{bash_completion_destination}`
          if $?.exitstatus == 0
            puts 'File successfully removed.'
          end
        else
          puts bash_completion_destination + ' not found.'
        end

      end

    end
  end

end

