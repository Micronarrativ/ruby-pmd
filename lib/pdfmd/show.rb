#
# Show function of pdfmd
#
filename        = ENV.fetch('PDFMD_FILENAME')
optTag          = ENV['PDFMD_TAGS'] || nil 
optAll          = ENV['PDFMD_ALL'] == 'true' ? true : nil
opt_format      = ENV['PDFMD_FORMAT']
opt_includepdf  = ENV['PDFMD_INCLUDEPDF']
hieraDefaults   = queryHiera('pdfmd::config')

# Determine includepdf from Hiera if possible
if not opt_includepdf.nil? and
  opt_includepdf == 'true'

  opt_includepdf = true

elsif opt_includepdf.nil? and
  not hieraDefaults['show'].nil? and
  not hieraDefaults['show']['includepdf'].nil? and
  hieraDefaults['show']['includepdf'] == true

  opt_includepdf = true
  
else

  opt_includepdf = false

end

# Determine format from Hiera if possible
if opt_format.nil? and
  not hieraDefaults['show'].nil? and
  not hieraDefaults['show']['format'].nil? and
  hieraDefaults['show']['format'] != ''

  opt_format = hieraDefaults['show']['format']

end


# Determine tags from Hiera if possible
if optTag.nil? and
  not hieraDefaults['show'].nil? and
  not hieraDefaults['show']['tag'].nil? and
  hieraDefaults['show']['tag'] != ''

  optTag = hieraDefaults['show']['tag']

end

metadata  = readMetadata(filename)

if optAll or optTag.nil?

  # Sort the keys in the hash in a specific order, so it becomes predictable
  sortedHash = Hash.new
  sortedHash['author']      = metadata['author']
  sortedHash['creator']     = metadata['creator']
  sortedHash['createdate']  = metadata['createdate']
  sortedHash['title']       = metadata['title']
  sortedHash['subject']     = metadata['subject']
  sortedHash['keywords']    = metadata['keywords']
  metadata = sortedHash

  tags = metadata.keys.join(',').split(',')
else
  tags = optTag.split(',')
end

# Format the output according to the spefications.
# Default output is for Human readable
#
case opt_format
when /yaml/i

  # Format the output as YAML

  require 'yaml'
  yamlData = Hash.new
  tags.each do |tagname|
    yamlData[tagname] = metadata[tagname.downcase]
  end

  # Include the filename if required
  if opt_includepdf
    fullHash            = Hash.new
    fullHash[filename]  = yamlData
    puts fullHash.to_yaml
  else
    puts yamlData.to_yaml
  end

when /hash/i

  # Format the output as Ruby Hash

  hashData = Hash.new
  tags.each do |tagname|
    hashData[tagname] = metadata[tagname.downcase]
  end

  # Include filename if required
  if opt_includepdf
    fullHash = Hash.new
    fullHash[filename] = hashData
    puts fullHash
  else
    puts hashData
  end

when /csv/i

  # Format the output as CSV data (or what could be interpreted as something
  # similar

  # Format the fields as CSV
  csvData = Hash.new
  tags.each do |tagname|
    csvData[tagname] = '"' + metadata[tagname.downcase].to_s.gsub(/"/,'""') + '"'
  end

  # Include the filename if required
  if opt_includepdf
    # Hash to array and joined to CSV compatible string
    puts "\"#{filename}\"," + csvData.values.join(',')
  else
    # Hash to array and joined to CSV compatible string
    puts csvData.values.join(',')
  end


when /json/i

  # Format the output as JSON

  require 'json'
  jsonData = Hash.new
  tags.each do |tagname|
    jsonData[tagname] = metadata[tagname.downcase]
  end

  # Include the filename if required
  if opt_includepdf
    fullHash = Hash.new
    fullHash[filename] = jsonData
    puts fullHash.to_json
  else
    puts jsonData.to_json
  end

else

  # Default output for humans to read
  if opt_includepdf
    puts 'File: ' + filename
  end
  tags.each do |key,tag|
    puts key.capitalize + ': ' + metadata[key.downcase]
  end

end

