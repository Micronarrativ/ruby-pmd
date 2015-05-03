#
# == File: config.rb
#
# Show the current default configuration settings
#

# Options
opt_show    = ENV.fetch('PDFMD_SHOW')
opt_command = ENV.fetch('PDFMD_COMMAND').downcase

require_relative '../string_extend.rb'
require 'yaml'
require 'pp'

#
# If now options are set,
# show the current settings
if opt_show.blank? or opt_show == 'true'
  opt_show = true
end

# Show the current settings
case opt_show
when true

  # As long as only Hiera is supported as external storage
  # for configuration (unless I need it otherwise), read the
  # hiera configuration
  puts 'Current default configuration:'
  puts ''
  hieraConfig = eval `hiera pdfmd::config`

  # Show the configuration only for one key
  if not opt_command.empty? and

    hieraConfig.has_key?(opt_command)

    puts 'Command: ' + opt_command
    puts hieraConfig[opt_command].to_yaml
    puts ''

  # Strange key provided. Typo? Anyway: error
  elsif not opt_command.empty? and
    not hieraConfig.has_key?(opt_command)

    puts "Command '#{opt_command}' not found in default configuration."

  # Show all configuration from Hiera
  else

    hieraConfig.sort.each do |key,value|
      puts 'Command: ' + key
      puts value.to_yaml
      puts ''
    end

  end

end
