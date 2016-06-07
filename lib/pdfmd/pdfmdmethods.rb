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
  def determineValidSetting(manualSetting,key)

    if !@hieradata.nil? 
      hieraKey    = '@hieradata'
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
      self.log('debug', "Chosing manual setting '#{key} = #{manualSetting}'.")

      # if manualSetting is date, the actual field meant is "'create date'", not 'date'.
      manualSetting = manualSetting.gsub('date:', 'createdate:')

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
  def log(status = 'info', message)

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
  def queryHiera(keyword, facts = 'UNSET')

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
