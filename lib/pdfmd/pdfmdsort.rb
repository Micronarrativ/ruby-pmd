# == Class: pdfmdsort
#
# TODO: Author values with a slave One/two should be sorted into one/two/yyyymmdd-one_to-xxx.pdf
class Pdfmdsort < Pdfmd

  require 'fuzzystringmatch'

  attr_accessor :filename, :dryrun, :copy, :interactive, :destination, :overwrite, :typo

  # Initialize
  def initialize(input)
      super input
      @stringSimBorder = 0.8  # Defines the value of the typo check
      @destination     = '.'
      @interactive     = false
      @copy            = false
      @dryrun          = false
      @overwrite       = false
      @typo            = false
  end


  #
  # Check if the destination is valid
  def checkDestination

    log('debug', "Checking destination parameter '#{@destination}'.")

    if File.file?(@destination)
      log('error', "Destination '#{@destination}' is a file.")
      false
    else
      log('debug', "Destination '#{@destination}' as directory confirmed.")
      true
    end

  end

  #
  # Get the author
  # Return 'false' if no author is being found.
  def get_author()
    if not self.check_metatags('author')
      return false
    end
    author = @@metadata['author'].gsub(/\./,'_').gsub(/\&/,'').gsub(/\-/,'_').gsub(/\s/,'_').gsub(/\,/,'_').gsub(/\_\_/,'_')
    I18n.enforce_available_locales = false
    I18n.transliterate(author).downcase # Normalising
  end

  # Method compares string from 'targetdir' with all subfolders in the targetdir
  #   in order to find similarities in writing.
  def findSimilarTargetdir( targetdir )

    self.log('debug', "Running method 'findSimilarTarget' with parameter '#{targetdir}'.")

    fuzzy       = FuzzyStringMatch::JaroWinkler.create( :native )
    returnValue = false

    # Get all subfolders 
    subDirectories = Dir[@destination + '/*']
    subDirectories.each do |fullPathFolder|
       stringSimilarity = fuzzy.getDistance( 
         fullPathFolder.gsub(@destination + '/', ''),
         targetdir.gsub(@destination + '/', '')
         )
       if stringSimilarity > @stringSimBorder
         self.log('debug', "findSimilarTargetdir: Found String value #{stringSimilarity.to_s} for target '#{fullPathFolder}'.")
         returnValue = fullPathFolder
       end
    end
    returnValue
  end


  #
  # Sort the file away
  def sort
    if self.checkDestination

      if @interactive
        answer = readUserInput("Process '#{@filename}' ([y]/n): ")
        answer = answer.empty? ? 'y' : answer
        self.log('info', "User Answer for file '#{@filename}': #{answer}")
        if !answer.match(/y/)  
          self.log('info',"Skipping file '#{@filename}' due to user answer: '#{answer}'.")
          return
        else
          self.log('info',"Processing file '#{@filename}' due to user answer: '#{answer}'.")
        end
      end

      if not author = get_author() or author.empty?
        self.log('error', "File '#{@filename}' has not value for author set. Cannot sort file. Abort.")
        exit 1
      end
      targetdir   = @destination.chomp + '/' + author
      targetfile  = targetdir + '/' + Pathname.new(@filename).basename.to_s

      # Create the target directory, if it does not exist yet.
      if !File.exists? targetdir

        # Check for similiar directory names which might indicate a typo in the
        #   current directory name.
        if @typo and foundDir = self.findSimilarTargetdir(targetdir)

          self.log('info', "Similar target found ('" + foundDir + "'). Request user input.")
          puts 'Similar target directory detected:'
          puts 'Found : ' + foundDir
          puts 'Target: ' + targetdir
          while answer = readUserInput('Abort? ([y]/n): ')
            if answer.match(/(y|yes|j|ja|^$)/i)
              self.log('info','User chose to abort sorting.')
              puts 'Abort.'
              exit 0
            elsif answer.match(/(n|no)/i)
              self.log('info', 'User chose to continue sorting.')
              break
            end
          end
        end

        if @dryrun
          self.log('info', "Dryrun: Created Directory '#{targetdir}'.")
        else
          self.log('info', "Created directory '#{targetdir}'.")
          puts 'Created: ' + targetdir
          FileUtils.mkdir_p(targetdir)
        end
      end

      # Check if the file already exists
      # This does nothing so far
      if File.exists?(targetfile) and @overwrite
        self.log('info', "File '#{@filename}' already exists. Overwrite active: replacing file.")
      elsif File.exists?(targetfile) and !@overwrite
        self.log('info', "File '#{@filename}' already exists, overwrite disabled: not replacing file.")
        return true
      end

      if @copy

        if @dryrun
          self.log('info', "Dryrun: Copy file '#{@filename}' to '#{targetdir}'.")
        else
          self.log('info', "Copy file '#{@filename}' to '#{targetdir}'.")
          FileUtils.cp(@filename, targetdir)
        end

      else

        if @dryrun
          self.log('info', "Dryrun: Move file '#{@filename}' to '#{targetdir}'.")
        else
          self.log('info', "Move file '#{@filename}' to '#{targetdir}'.")
          FileUtils.mv(@filename, targetdir)
        end

      end

    end
  end

end
