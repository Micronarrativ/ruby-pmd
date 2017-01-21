# == Class: Pdfmdconfig
#
# Show current default configuration of pdfmd
#
class Pdfmdconfig < Pdfmd

  require 'yaml'

  def initialize
  end

  def show_config(key = '')

    if key.empty?
      Pdfmdmethods.log('debug','Showing current configuration in yaml format.')
      @@hieradata.to_yaml
    elsif @@hieradata.has_key?(key)
      Pdfmdmethods.log('debug',"Showing current configuration in yaml format, section: #{key}.")
      @@hieradata[key].to_yaml
    else
      Pdfmdmethods.log('error',"Unknown Hiera Key used: '#{key}'.")
      raise ("Error: Unknown hiera key '#{key}'. Abort.")
    end

  end

end
