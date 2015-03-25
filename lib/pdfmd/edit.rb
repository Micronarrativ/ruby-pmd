#
# Thor command 'edit' for changing the common
# ExifTags within the PDF file
#
filename  = ENV.fetch('PDFMD_FILENAME')
optTag    = ENV['PDFMD_TAG'] || nil
optRename = ENV['PDFMD_RENAME'] == 'true' ? true : false
pdfmd     = ENV['PDFMD']


metadata = readMetadata(filename)

if optTag == 'all'
  tags = ['author','title','subject','createdate','keywords']
else
  tags = optTag.split(',')
end
tags.each do |currentTag|

  # Change the tag to something we can use here
  puts "Current value: '#{metadata[currentTag.downcase]}'"
  answer   = readUserInput("Enter new value for #{currentTag} :")
  if currentTag.downcase == 'createdate'
    while not answer = identifyDate(answer)
      puts 'Invalid date format'
      answer = readUserInput("Enter new value for #{currentTag} :")
    end
  end
  puts "Changing value for #{currentTag}: '#{metadata[currentTag]}' => #{answer}"
  `exiftool -#{currentTag.downcase}='#{answer}' -overwrite_original '#{filename}'`
end

#
# If required, run the renaming task afterwards
# This is not pretty, but seems to be the only way to do this in THOR
#
if optRename
  `#{pdfmd} rename '#{filename}'`
end

