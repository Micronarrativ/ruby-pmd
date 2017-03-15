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

# Method to validate a given input date
# This is duplicate of the method in pdfmd edit class
# Dates in format YYYY:mm:dd will be preferred. Fallback to the format of YYYY:dd:mm has a lower priority
def Pdfmdmethods.validateDate(date)

  year     = '[1-2][0-9][0-9][0-9]'
  month    = '0[1-9]|10|11|12'
  day      = '[1-9]|0[1-9]|1[0-9]|2[0-9]|3[0-1]'
  hour     = '[0-1][0-9]|2[0-3]|[1-9]'
  minute   = '[0-5][0-9]'
  second   = '[0-5][0-9]'
  timezone = '(\+[\d]{2}\:[\d]{2})?'
  case date
  # Catch YYYYmmdd
  when /^(#{year})(#{month})(#{day})$/
    m_year                   = $1
    m_month                  = $2
    m_day                    = $3
    m_hour, m_minute, m_second = ['00'] * 3
  # catch YYYYddmm
  when /^(#{year})(#{day})(#{month})$/
    m_year                   = $1
    m_month                  = $3
    m_day                    = $2
    m_hour, m_minute, m_second = ['00'] * 3
  # Catch YYYYmmddHHMMSS
  when /^(#{year})(#{month})(#{day})(#{hour})(#{minute})(#{second})$/
    m_year   = $1
    m_month  = $2
    m_day    = $3
    m_hour   = $4
    m_minute = $5
    m_second = $6
  # Catch YYYYddmmHHMMSS
  when /^(#{year})(#{day})(#{month})(#{hour})(#{minute})(#{second})$/
    m_year   = $1
    m_month  = $3
    m_day    = $2
    m_hour   = $4
    m_minute = $5
    m_second = $6
  # Catch YYYY:mm:dd HH:MM:SS[+x]
  when /^(#{year})[\:|\.|\-|\/](#{month})[\:|\.|\-|\/](#{day})\s(#{hour})[\:](#{minute})[\:](#{second})(#{timezone})$/
    m_year   = $1
    m_month  = $2
    m_day    = $3
    m_hour   = $4
    m_minute = $5
    m_second = $6
  # Catch YYYY:dd:mm HH:MM:SS
  when /^(#{year})[\:|\.|\-|\/](#{day})[\:|\.|\-|\/](#{month})\s(#{hour})[\:](#{minute})[\:](#{second})(#{timezone})$/
    m_year   = $1
    m_month  = $2
    m_day    = $3
    m_hour   = $4
    m_minute = $5
    m_second = $6
  # Catch YYYY:mm:dd
  when /^(#{year})[\:|\.|\-|\/](#{month})[\:|\.|\-|\/](#{day})$/
    m_year = $1
    m_month = "%02d" % $2
    m_day   = "%02d" % $3
    m_hour, m_minute, m_second = ['00'] * 3
  # Catch YYYY:dd:mm
  when /^(#{year})[\:|\.|\-|\/](#{day})[\:|\.|\-|\/](#{month})$/
    m_year = $1
    m_month = "%02d" % $3
    m_day   = "%02d" % $2
    m_hour, m_minute, m_second = ['00'] * 3
  else
    # This date was not recognized.

    return false
  end

  if $2 > '12' and
    $3 < '13'
    warn("Unconventional date ('#{date}') seen. Adjusted to format 'YYYY:mm:dd'")
    m_month = $3
    m_day   = $2
  end

  return m_year + ':' + m_month + ':' + m_day + ' ' + m_hour + ':' + m_minute + ':' + m_second
end


