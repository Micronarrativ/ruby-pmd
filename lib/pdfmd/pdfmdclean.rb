# == Class: pdfmdclean
#
# Clean metadata from a document
#
class Pdfmdclean < Pdfmd

  attr_accessor :filename, :tags

  def initialize(filename)
    super(filename)
  end

  # Run the actual cleaning
  def run()

    # Figure out which tags actually to reset.
    if @tags.is_a?(String) and @tags != 'all'
      @tags = @tags.split(',')
    else
      @tags = @@default_tags
    end

    # Create the command to delete all the metatags
    command   = 'exiftool'
    parameter = ' -overwrite_original'
    @tags.each do |current_tag|
      parameter << " -#{current_tag}="
    end
    parameter << ' ' 

    `#{command} #{parameter} "#{@filename}"`
#    self.log('info', "Cleaning tags '#{@tags.join(', ').to_s}' from file '#{@filename}'.")
  end

end
