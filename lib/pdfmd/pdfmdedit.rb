# == Class: pdfmdedit
#
# Edit Metadata of PDF documentsc
#
class Pdfmdedit < Pdfmd

  attr_accessor :filename, :opendoc, :pdfviewer, :hieradata

  def initialize
    @edit_tags = Hash.new
  end

  # Start a viewer
  def start_viewer(filename = '', viewer = '')
    if File.exists?(filename) and !viewer.empty?

      pid = IO.popen("#{viewer} '#{filename}' 2>&1")
      Pdfmdmethods.log('debug', "Application '#{viewer}' with PID #{pid.pid} started to show file '#{filename}'.")
      pid.pid

    elsif viewer.empty?
      Pdfmdmethods.log('error', 'No viewer specified. Aborting document view.')
    else
      Pdfmdmethods.log('error', "Could not find file '#{filename}' for viewing.")
    end

  end


  #
  # Setting the tags to edit
  # Edit_tags is a hash
  # - empty values will be queried from the user
  # - set values will be applied.
  def set_tags(tags = Array.new)

    # Set default tags to edit tags
    if tags.is_a?(String) and tags.downcase == 'all'
      DEFAULT_TAGS.each do |value|
        @edit_tags[value] = ''
      end
    elsif tags.is_a?(Array)
      tags.each do |value|
        @edit_tags[value] = ''
      end

    else

      # Try to match tags
      if tags.is_a?(String)

        @edit_tags = {}
        tagsForEditing = tags.split(',')
        tagsForEditing.each do |value|

          # Matchin for seperator
          separator = @@edit_separator
          if value.match(/#{separator}/)

            Pdfmdmethods.log('debug', 'Found tag value assignment.')
            tagmatching = value.split(separator)

            # Check date for validity
            if tagmatching[0].downcase == 'createdate'
              tagmatching[1].gsub!(/^'|'$/,'') # Remove any apostrophes
              validatedDate = validateDate(tagmatching[1])
              if !validatedDate
                Pdfmdmethods.log('error',"Date not recognized: '#{tagmatching[1]}'.")
                raise 'Error: Date format not recognized. Abort.'
              else
                Pdfmdmethods.log('debug',"Identified date: #{validatedDate} ")
                @edit_tags[tagmatching[0].downcase] = validatedDate
              end
            else
              value = tagmatching[1].gsub(/^'|'$/,'')
              Pdfmdmethods.log('debug', "Identified key #{tagmatching[0]} with value '#{value}.")
              @edit_tags[tagmatching[0].downcase] = value
            end
          else
            @edit_tags[value.downcase] = ''
          end

        end

      end

    end

  end


  #
  # Update the tags
  #   Reads @@edit_tags and asks for updates from the user if no value in
  #   @@edit_tags is provided
  def update_tags()

    # Validate the createdate and clean it from the hash if it's not validated
    if not self.validateDate(@@metadata['createdate']) and not @edit_tags.has_key?('createdate')
      puts 'Warning. CreateDate \'' + @@metadata['createdate'] + '\' not valid!. Resetting date.'
      @edit_tags['createdate'] = ''
    end

    # Empty String for possible viewer Process PID
    viewerPID = ''

    # Iterate through all tags and request information from user
    #   if necessary
    @edit_tags.each do |key,value|

      if value.empty?

        # At this poing:
        # 1. If @opendoc
        # 2. viewerPID.empty? (no viewer stated)
        # => Start the viewer
        if @opendoc and viewerPID.to_s.empty?
          viewerPID = start_viewer(@filename, @pdfviewer)
          Pdfmdmethods.log('debug', "Started external viewer '#{@pdfviewer}' with file '#{@filename}' and PID: #{viewerPID}")
        end

        puts 'Changing ' + key.capitalize + ', current value: ' + @@metadata[key].to_s

        # Save the current value
        current_value = @@metadata[key]

        # Validate Check for date input
        if key.downcase == 'createdate'

          # Repeat asking for a valid date
          validatedDate = false
          while !validatedDate
            userInput = readUserInput('New date value: ')

            if userInput.empty? and !current_value.empty?
              @@metadata[key] = current_value
              Pdfmdmethods.log('debug', "User decided to take over old value for #{key}.")
              puts 'Date is needed. Setting old value: ' + current_value
              break
            end

            # Update loop condition variable
            validatedDate = validateDate(userInput)

            # Update Metadata
            @@metadata[key.downcase] = validatedDate

          end

          # Input of all other values
        else

          @@metadata[key.downcase] = readUserInput('New value: ')

        end

      else

        # Setting the new metadata
        @@metadata[key.downcase] = value

      end
    end

    # Close the external PDF viewer if a PID has been set.
    if !viewerPID.to_s.empty?
      `kill #{viewerPID}`
      `pkill -f "#{@pdfviewer} #{@filename}"` # Double kill
      Pdfmdmethods.log('debug', "Viewer process with PID #{viewerPID} killed.")
    end

  end

  #
  # Function to validate and interprete date information
  def validateDate(date)

    year    = '[1-2][0-9][0-9][0-9]'
    month   = '0[1-9]|10|11|12'
    day     = '[1-9]|0[1-9]|1[0-9]|2[0-9]|3[0-1]'
    hour    = '[0-1][0-9]|2[0-3]|[1-9]'
    minute  = '[0-5][0-9]'
    second  = '[0-5][0-9]'
    identifiedDate = case date
    when /^(#{year})(#{month})(#{day})$/
      $1 + ':' + $2 + ':' + $3 + ' 00:00:00'
    when /^(#{year})(#{month})(#{day})(#{hour})(#{minute})(#{second})$/
      $1 + ':' + $2 + ':' + $3 + ' ' + $4 + ':' + $5 + ':' + $6
    when /^(#{year})[\:|\.|\-|\/](#{month})[\:|\.|\-|\/](#{day})\s(#{hour})[\:](#{minute})[\:](#{second})$/
      $1 + ':' + $2 + ':' + $3 + ' ' + $4 + ':' + $5 + ':' + $6
    when /^(#{year})[\:|\.|\-|\/](#{month})[\:|\.|\-|\/](#{day})$/
      day   = "%02d" % $3
      month = "%02d" % $2
      # Return the identified string
      $1 + ':' + month + ':' + day + ' 00:00:00'
    else

      # This wasn't a date we recognize
      false

    end
    return identifiedDate
  end

  #
  # Write tags from the @@metadata back into the file
  def write_tags(filename)

    filename.empty? ? filename = @filename : ''

    commandparameter = '-overwrite_original'
    @@metadata.each do |key,value|
      commandparameter = commandparameter + " -#{key}=\"#{value}\""
    end

    if !@@documentPassword.to_s.empty?
      commandparameter = commandparameter + " -password '#{@@documentPassword}'"
    end

    command = "exiftool #{commandparameter} '#{filename}'"
    `#{command}`
    Pdfmdmethods.log('info',"Updating '#{filename}' with " + commandparameter.gsub(/\s\-password\s\'.*\'/,'').gsub(/\-overwrite\_original\s/,'').gsub(/\'\s\-/,"', ").gsub(/\-/,' ') )

  end

end
