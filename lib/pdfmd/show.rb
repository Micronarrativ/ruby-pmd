filename  = ENV.fetch('PDFMD_FILENAME')
optTag    = ENV['PDFMD_TAGS'] || nil 
optAll    = ENV['PDFMD_ALL'] == 'true' ? true : nil

metadata  = readMetadata(filename)

# Output all metatags
if optAll or optTag.nil?

  puts "Author      : " + metadata['author'].to_s
  puts "Creator     : " + metadata['creator'].to_s
  puts "CreateDate  : " + metadata['createdate'].to_s
  puts "Subject     : " + metadata['subject'].to_s
  puts "Title       : " + metadata['title'].to_s
  puts "Keywords    : " + metadata['keywords'].to_s

elsif not optTag.nil? # Output specific tag(s)

  tags = optTag.split(',')
  tags.each do |tag|
    puts metadata[tag.downcase]
  end

end
