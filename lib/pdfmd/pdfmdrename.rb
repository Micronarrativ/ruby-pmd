# == Class: pdfmdrename
#
# Class for renaming the file according to the metadata
#
class Pdfmdrename < Pdfmd

  attr_accessor :filename, :dryrun, :allkeywords, :outputdir, :nrkeywords, :copy

  # document key mappings to determine the document type based on the
  # string in the meta field 'title'
  @@keymapping = {
    'cno' => ['Customer','Customernumber'],
    'con' => ['Contract'],
    'inf' => ['Information'],
    'inv' => ['Invoice', 'Invoicenumber'],
    'man' => ['Manual'],
    'off' => ['Offer', 'Offernumber'],
    'ord' => ['Order', 'Ordernumber'],
    'rec' => ['Receipt', 'Receiptnumber'],
    'tic' => ['Ticket'],
    }

  def initialize(filename)
    super(filename)
    @nrkeywords     ||= 3

    # Find the valid keymapping
    # Use @@keymapping as default and only overwrite when provided by hiera.
    hierakeymapping = self.determineValidSetting(nil, 'rename:keys')
    hierakeymapping ?  @@keymapping = hierakeymapping : ''

    # FIXME: this default doctype assignment might need to be rewritten as the keymapping above.
    @defaultDoctype = self.determineValidSetting('doc', 'rename:defaultdoctype')
    @fileextension  = 'pdf'
  end

  def rename

    # Build new filename elements
    newFilename             = Hash.new
    newFilename[:date]      = @@metadata['createdate'].gsub(/\ \d{2}\:\d{2}\:\d{2}.*$/,'').gsub(/\:/,'')
    newFilename[:author]    = get_author()
    newFilename[:doctype]   = get_doctype()
    newFilename[:title]     = @@metadata['title'].downcase
    newFilename[:subject]   = @@metadata['subject'].downcase.gsub(/(\s|\-|\.|\&|\%)/,'_')
    newFilename[:keywords]  = get_keywords(get_keywordsPreface(newFilename))
    newFilename[:extension] = @fileextension
    newFilename[:outputdir] = get_outputdir(@outputdir)

    command = @copy ? 'cp' : 'mv'

    filetarget  = get_filename(newFilename)
    if @dryrun # Do nothing on dryrun
      if @filename == filetarget
        self.log('info', "Dryrun: File '#{@filename}' already has the correct name. Doing nothing.")
      else
        self.log('info',"Dryrun: Renaming '#{@filename}' to '#{get_filename(newFilename)}'.")
      end
    elsif @filename == filetarget # Do nothing when name is already correct.
      self.log('info',"File '#{@filename}' already has the correct name. Doing nothing.")
    else
      self.log('info',"Renaming '#{@filename}' to '#{filetarget}'.")
      command     = command + " '#{@filename}' #{filetarget} 2>/dev/null"
      system(command)
      if !$?.exitstatus
        log('error', "Error renaming '#{@filename}' to '#{filetarget}'.")
        abort
      else
        log('info', "Successfully renamed file to '#{filetarget}'.")
      end

    end
  end

  #
  # Return the filename from the available filedata
  def get_filename(filedata = {})

    if filedata.size > 0

      # Create the filename out of all with some exceptions
      #
      # If the doctype is the default one, the first keywords are the
      # title and the subject
      if filedata[:doctype] == @defaultDoctype

        # The subject and title is part of the keywords and handled there.
        filedata[:outputdir] + '/' +
          filedata[:date] + '-' +
          filedata[:author] + '-' +
          filedata[:doctype] + '-' +
          filedata[:keywords] + '.' +
          filedata[:extension]
      else
        filedata[:outputdir] + '/' + filedata.except(:extension, :title, :subject, :outputdir).values.join('-') + '.' + filedata[:extension]
      end

    else

      false

    end

  end

  # Validate the output directory
  def get_outputdir(outputdir = '')

    if !outputdir # outputdir is set to false, assume pwd
      self.log('debug','No outputdir specified. Taking current pwd of file.')
      outputdir = File.dirname(@filename)
    elsif outputdir and !File.exist?(outputdir)
      puts "Error: output directory '#{outputdir}' not found. Abort."
      self.log('error',"Output directory '#{outputdir}' not accessible. Abort.")
      exit 1
    elsif outputdir and File.exist?(outputdir)
      outputdir
    else
      false
    end

  end

  # Get the keywords
  def get_keywords(preface = '')

    if !@@metadata['keywords'].empty?

      keywordsarray = @@metadata['keywords'].split(',')
      # Replace leading spaces and strings from the keymappings
      # if the value is identical it will be placed at the beginning
      # of the array (and therefore be right after the preface in the filename)
      keywordsarraySorted = Array.new
      keywordsarray.each_with_index do |value,index|
        value = value.lstrip.chomp

        @@keymapping.each do |abbreviation,keyvaluearray|
          if keyvaluearray.kind_of?(String)
            keyvaluearray = keyvaluearray.split(',')
          end
          keyvaluearray = keyvaluearray.sort_by{|size| -size.length}
          keyvaluearray.each do |keystring|
            value = value.gsub(/#{keystring.lstrip.chomp}\s?/i, abbreviation.to_s)
          end
        end

        # Remove special characters from string
        keywordsarray[index] = value.gsub(/\s|\/|\-|\./,'_')

        # If the current value matches some of the replacement abbreviations,
        # put the value at index 0 in the array. It will then be listed earlier in the filename.
        if value.match(/^#{@@keymapping.keys.join('|')} /i)
          keywordsarraySorted.insert(0, keywordsarray[index])
        else
          keywordsarraySorted.push(keywordsarray[index])
        end

      end

      # Insert the preface if it is not empty
      if !preface.to_s.empty?
        keywordsarraySorted.insert(0, preface)
      end

      # Convert the keywordarray to a string an limit the number
      # of keywords according to @nrkeywords or the parameter 'all'
      if @@metadata['keywords'] = !@allkeywords
        keywords = keywordsarraySorted.values_at(*(0..@nrkeywords-1)).join('-')
      else
        keywords = keywordsarraySorted.join('-')
      end

      # Normalize all keywords and return value
      I18n.enforce_available_locales = false
      I18n.transliterate(keywords).downcase.chomp('-')

    else # Keywords metafield is empty :(
      # So we return nothing or the preface (if available)

      !preface.empty? ? preface : ''

    end

  end



  # Get the preface for the keywords
  # If the title is meaningful, then the
  # subject will become the preface ( = first keyword)
  # If the subject matches number/character combination and contains no spaces,
  # the preface will be combined with the doctype.
  # If not: The preface will contain the whole subject with dots and spaces being
  # replaced with underscores.
  def get_keywordsPreface(filedata = {})

    I18n.enforce_available_locales = false
    if filedata[:doctype].nil? or filedata[:doctype].empty?
      filedata[:doctype] = @defaultDoctype
    end

    if !filedata[:subject].nil? and !filedata[:subject].empty? and
      !filedata[:doctype] == @defaultDoctype

      I18n.transliterate(filedata[:subject])

    else

      # Document matches standard document type.
      # title and subject are being returned.

      # Normalize special characters
      title   = @@metadata['title'].downcase
      subject = !filedata[:subject].empty? ? '_' + filedata[:subject].downcase : ''
      subject = subject.gsub(/\s|\-|\&/, '_')
      I18n.transliterate(title + subject)

    end

  end

  # Get the doctype from the title
  #
  def get_doctype()
    doctype = @defaultDoctype
    @@keymapping.each do |key,value|
      value.kind_of?(String) ? value = value.split : ''
      value.each do |keyword|
        @@metadata['title'].match(/#{keyword}/i) ? doctype = key : ''
      end
    end
    doctype.downcase
  end

  # Get the author from the metatags and
  # normalize the string
  def get_author()
    author = @@metadata['author'].gsub(/\./,'_').gsub(/\&/,'').gsub(/\-/,'').gsub(/\s|\//,'_').gsub(/\,/,'_').gsub(/\_\_/,'_')
    I18n.enforce_available_locales = false
    I18n.transliterate(author).downcase # Normalising
  end

end
