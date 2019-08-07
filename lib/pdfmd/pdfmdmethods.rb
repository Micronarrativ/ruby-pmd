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
  def Pdfmdmethods.determineValidSetting(manualSetting,key)

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
      #self.log('debug', "Chosing manual setting '#{key} = #{manualSetting}'.")

      # if manualSetting is date, the actual field meant is "'create date'", not 'date'.
      key = key.gsub('date:', 'createdate:')

      manualSetting
    elsif !hieraValue.nil? or
      !hieraValue == ''

      #self.log('debug', "Chosing hiera setting '#{key} = #{hieraValue}'.")
      hieraValue

    else
      #self.log('debug', "No setting chosen for '#{key}' in hiera.")
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
  # Method to return the configuration 
  #
  # This method will try to find the local configuration file, reads its values
  # and returns them as hash.
  def Pdfmdmethods.readConfig()
    
    # This hierarchy is important!
    # These are yaml files for god sake.
    # Can't get it to work in ini format.
    defaultLocations = [
      '~/.pdfmd.cfg',
      '~/.pdfmd.yml',
      '~/.pdfmd.yaml',
      '~/.config/pdfmd/config',
      '~/.config/pdfmd/pdfmd.cfg',
      '~/.config/pdfmd/pdfmd.yml',
      '~/.config/pdfmd/pdfmd.yaml',
      '/etc/pdfmd.cfg',
      '/etc/pdfmd.yml',
      '/etc/pdfmd.yaml',
      '/etc/pdfmd/pdfmd.cfg',
      '/etc/pdfmd/pdfmd.yml',
      '/etc/pdfmd/pdfmd.yaml'
    ]

    # Find the first config file
    for location in defaultLocations.each do

      if File.file?(File.expand_path(location))
        path_configfile = File.expand_path(location)
        break
      end
    end

    if not path_configfile
      return {}
    else
      return YAML.load_file(File.expand_path(path_configfile))
    end
  end

end

#
# Initializing or removing the bash_completion file
def Pdfmdmethods.init_bashcompletion(name, version, remove = false)

  # Find the current local path where the original bash completion file might be hiding.
  paths = [
    "#{File.dirname(File.expand_path($0))}/../lib",
    "#{Gem.dir}/gems/#{name}-#{version}/lib",
  ]
  bash_completion_destination = '/etc/bash_completion.d/pdfmd.bash'
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

