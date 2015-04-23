# Standard Show
# Test 001
initTmpDir
commandparameter = ' show -i false --format standard --all'
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = 'Author: Example Author
Creator: Writer
Createdate: 1970:01:01 00:00:00
Title: Test Dokument
Subject: Test Subject
Keywords: Some Keywords, Author, some feature, Customernumber 1111111, Kundenummer 1111111'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults = { '001' => {:result => result, :command => commandparameter }}

# Show single tags
# Test 002
initTmpDir
commandparameter = ' show -t author --format standard'
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = 'Author: Example Author'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('002', {:result => result, :command => commandparameter })

# Test 003
# Show multiple tags
initTmpDir
commandparameter = ' show -t author,subject --format standard'
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = 'Author: Example Author
Subject: Test Subject'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('003', {:result => result, :command => commandparameter })

# Test 004
# Show output as YAML format
initTmpDir
commandparameter = ' show -t author,subject -f yaml'
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = '---
author: Example Author
subject: Test Subject'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('004', {:result => result, :command => commandparameter })

# Test 005
# Show output as JSON format
initTmpDir
commandparameter = ' show -f json -a'
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = '{"author":"Example Author","creator":"Writer","createdate":"1970:01:01 00:00:00","title":"Test Dokument","subject":"Test Subject","keywords":"Some Keywords, Author, some feature, Customernumber 1111111, Kundenummer 1111111"}'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('005', {:result => result, :command => commandparameter })

# Test 006
# Show output as CSV format
initTmpDir
commandparameter = ' show -t author,subject -f csv -a'
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = '"Example Author","Writer","1970:01:01 00:00:00","Test Dokument","Test Subject","Some Keywords, Author, some feature, Customernumber 1111111, Kundenummer 1111111"'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('006', {:result => result, :command => commandparameter })

# Test 007
# Show output as Hash format
initTmpDir
commandparameter = ' show -t author,subject -f hash -a'
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = '{"author"=>"Example Author", "creator"=>"Writer", "createdate"=>"1970:01:01 00:00:00", "title"=>"Test Dokument", "subject"=>"Test Subject", "keywords"=>"Some Keywords, Author, some feature, Customernumber 1111111, Kundenummer 1111111"}'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('007', {:result => result, :command => commandparameter })

