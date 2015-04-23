#
# == File: config.rb
#
# Show the current default configuration settings
#

# Options
opt_show = ENV.fetch('PDFMD_SHOW')

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
  # for configuration (unless I need otherwise), read the
  # hiera configuration
  puts 'Current default configuration:'
  puts ''
  hieraConfig = eval `hiera pdfmd::config`
  hieraConfig.sort.each do |key,value|
    puts 'Command: ' + key
    puts value.to_yaml
    puts ''
  end

end