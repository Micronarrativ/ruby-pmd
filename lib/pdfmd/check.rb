filename = ENV.fetch('PDFMD_FILENAME')

returnvalue = 0
readMetadata(filename).each do|key,value|
  if key.match(/author|subject|createdate|title/) and value.empty?
    puts 'Missing value: ' + key 
    returnvalue == 0 ? returnvalue = 1 : ''
  end
end
exit returnvalue
