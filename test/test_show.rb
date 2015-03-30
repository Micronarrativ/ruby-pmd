# Standard Show
# Test 001
initTmpDir
commandparameter = ' show '
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = 'Author      : Example Author
Creator     : Writer
CreateDate  : 1970:01:01 00:00:00
Subject     : Test Subject
Title       : Test Dokument
Keywords    : Some Keywords, Author, some feature, Customernumber 1111111, Kundenummer 1111111'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults = { '001' => {:result => result, :command => commandparameter }}

# Show single tags
# Test 002
initTmpDir
commandparameter = ' show -t author'
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = 'Example Author'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('002', {:result => result, :command => commandparameter })

# Test 003
# Show multiple tags
initTmpDir
commandparameter = ' show -t author,subject'
showContent = `#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
expectedContent = 'Example Author
Test Subject'
if showContent == expectedContent
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('003', {:result => result, :command => commandparameter })

