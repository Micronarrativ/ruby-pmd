# == Class: Pdfmdconfig
#
# Show current default configuration of pdfmd
#
class Pdfmdconfig < Pdfmd

  require 'yaml'

  def initialize(filename)
    super(filename)
    @filename = filename
  end

  def show_config(key = '')

    if key.empty?
      self.log('debug','Showing current configuration in yaml format.')
      @hieradata.to_yaml
    elsif @hieradata.has_key?(key)
      self.log('debug',"Showing current configuration in yaml format, section: #{key}.")
      @hieradata[key].to_yaml
    else
      self.log('error',"Unknown Hiera Key used: '#{key}'.")
      puts 'Unknown hiera key. Abort.'
      abort
    end

  end

end
