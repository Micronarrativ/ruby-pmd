# == Class: pdfmdedit
#
# Edit Metadata of PDF documentsc
#
class Pdfmdedit < Pdfmd

  attr_accessor :filename, :opendoc, :pdfviewer

  @@edit_tags = Hash.new

  def initialize(filename)
    super(filename)
    self.set_tags(@@default_tags)
  end


  # Start a viewer
  def start_viewer(filename = '', viewer = '')
    if File.exists?(filename) and !viewer.empty?

      pid = IO.popen("#{viewer} '#{filename}' 2>&1")
      self.log('debug', "Application '#{viewer}' with PID #{pid.pid} started to show file '#{filename}'.")
      pid.pid

    elsif viewer.empty?
      self.log('error', 'No viewer specified. Aborting document view.')
    else
      self.log('error', "Could not find file '#{filename}' for viewing.")
    end

  end


  #
  # Setting the tags to edit
  def set_tags(tags = Array.new)

    if tags.is_a?(String) and tags.downcase == 'all'
      @@default_tags.each do |value|
        @@edit_tags[value] = ''
      end
    elsif tags.is_a?(Array)
      tags.each do |value|
        @@edit_tags[value] = ''
      end
    elsif tags.is_a?(Hash)
      # NOTE: might need some adjustment here
      # Not sure this is used at all
      @@edit_tags = tags
    else


      # Try to match tags
      if tags.is_a?(String)

        @@edit_tags = {}
        tagsForEditing = tags.split(',')
        tagsForEditing.each do |value|

          if value.match(/:/)

            self.log('debug', 'Found tag value assignment.')
            tagmatching = value.split(':')

            # Check date for validity
            if tagmatching[0] == 'createdate'
              validatedDate = validateDate(tagmatching[1])
              if !validatedDate
                self.log('error',"Date not recognized: '#{tagmatching[1]}'.")
                abort 'Date format not recognized. Abort.'
              else
                self.log('debug',"Identified date: #{validatedDate} ")
                @@edit_tags[tagmatching[0]] = validatedDate
              end
            else
              self.log('debug', "Identified key #{tagmatching[0]} with value '#{tagmatching[1]}'.")
              @@edit_tags[tagmatching[0]] = tagmatching[1]
            end
          else
            @@edit_tags[value] = ''
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

    # Empty String for possible viewer Process PID
    viewerPID = ''

    # Iterate through all tags and request information from user
    #   if necessary
    @@edit_tags.each do |key,value|
      if value.empty?

        # At this poing:
        # 1. If @opendoc
        # 2. viewerPID.empty? (no viewer stated)
        # => Start the viewer
        if @opendoc and viewerPID.to_s.empty?
          viewerPID = start_viewer(@filename, @pdfviewer)
          self.log('debug', "Started external viewer '#{@pdfviewer}' with file '#{@filename}' and PID: #{viewerPID}")
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
              self.log('debug', "User decided to take over old value for #{key}.")
              puts 'Date is needed. Setting old value: ' + current_value
              break
            end

            # Update loop condition variable
            validatedDate = validateDate(userInput)

            # Update Metadata
            @@metadata[key] = validatedDate
          end

          # Input of all other values
        else

          @@metadata[key] = readUserInput('New value: ')

        end

      else

        # Setting the new metadata
        @@metadata[key] = value

      end
    end

    # Close the external PDF viewer if a PID has been set.
    if !viewerPID.to_s.empty?
      `kill #{viewerPID}`
      `pkill -f "#{@pdfviewer} #{@filename}"` # Double kill
      self.log('debug', "Viewer process with PID #{viewerPID} killed.")
    end

  end

  #
  # Function to validate and interprete date information
  def validateDate(date)

    year    = '[1-2][90][0-9][0-9]'
    month   = '0[1-9]|10|11|12'
    day     = '[1-9]|0[1-9]|1[0-9]|2[0-9]|3[0-1]'
    hour    = '[0-1][0-9]|2[0-3]|[1-9]'
    minute  = '[0-5][0-9]'
    second  = '[0-5][0-9]'
    case date
    when /^(#{year})(#{month})(#{day})$/
      identifiedDate =  $1 + ':' + $2 + ':' + $3 + ' 00:00:00'
    when /^(#{year})(#{month})(#{day})(#{hour})(#{minute})(#{second})$/
      identifiedDate =  $1 + ':' + $2 + ':' + $3 + ' ' + $4 + ':' + $5 + ':' + $6
    when /^(#{year})[\:|\.|\-](#{month})[\:|\.|\-](#{day})\s(#{hour})[\:](#{minute})[\:](#{second})$/
      identifiedDate =  $1 + ':' + $2 + ':' + $3 + ' ' + $4 + ':' + $5 + ':' + $6
    when /^(#{year})[\:|\.|\-](#{month})[\:|\.|\-](#{day})$/
      day   = "%02d" % $3
      month = "%02d" % $2

      # Return the identified string
      $1 + ':' + month + ':' + day + ' 00:00:00'

    else

      # This wasn't a date we recognize
      false

    end
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
    self.log('info',"Updating '#{filename}' with " + commandparameter.gsub(/\s\-password\s\'.*\'/,'').gsub(/\-overwrite\_original\s/,'').gsub(/\'\s\-/,"', ").gsub(/\-/,' ') )

  end

end
