# Standard renaming
# Test 001
initTmpDir
commandparameter = " rename -o #{TMPDIR} -c false "
`#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
files = readFilesInDir(TMPDIR)
if files.size == 1 and
  File.basename(files.keys[0]) == '19700101-example_author-doc-test_subject-cno1111111-some_keywords.pdf'
  result = 'OK'
else
  puts File.basename(files.keys[0])
  result = 'failed'
end
$testResults = { '001' => {:result => result, :command => commandparameter }}


# Test 002
# renaming with copy
initTmpDir
commandparameter = " rename -c -o #{TMPDIR}"
`#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
files = readFilesInDir(TMPDIR)
if files.size == 2 and
  File.basename(files.keys[0]) == '19700101-example_author-doc-test_subject-cno1111111-some_keywords.pdf'
  File.basename(files.keys[1]) == 'test_default.pdf'
  result = 'OK'
else
  puts File.basename(files.keys[0])
  result = 'failed'
end
$testResults.store('002', {:result => result, :command => commandparameter })

# Test 003
# Testing Dryrun
initTmpDir
commandparameter = ' rename -n '
`#{PDFMD} #{commandparameter} #{TARGETPDF} >>/dev/null`.chomp
files = readFilesInDir(TMPDIR)
if files.size == 1 and
  File.basename(files.keys[0]) == 'test_default.pdf'
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('003', {:result => result, :command => commandparameter })

# Test 004
# Testing all keywords (-a)
initTmpDir
commandparameter = " rename -a -o #{TMPDIR} -c false"
`#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
files = readFilesInDir(TMPDIR)
if files.size == 1 and
  File.basename(files.keys[0]) == '19700101-example_author-doc-test_subject-cno1111111-some_keywords-author-some_feature-kundenummer_1111111.pdf'
  result = 'OK'
else
  puts File.basename(files.keys[0])
  result = 'failed'
end
$testResults.store('004', {:result => result, :command => commandparameter })

# Test 005
# Testing number of keywords
# this might be buggy
initTmpDir
commandparameter = " rename -k 1 -o #{TMPDIR} -c false"
`#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
files = readFilesInDir(TMPDIR)
if files.size == 1 and
  File.basename(files.keys[0]) == '19700101-example_author-doc-test_subject.pdf'
  result = 'OK'
else
  puts File.basename(files.keys[0])
  result = 'failed'
end
$testResults.store('005', {:result => result, :command => commandparameter })

# Test 006
# Testing logging enabled
initTmpDir
commandparameter = " rename -l -p #{TMPDIR}/pdfmd.log -c false"
`#{PDFMD} #{commandparameter} #{TARGETPDF}`.chomp
files = readFilesInDir(TMPDIR)
if files.size == 1 and
  File.basename(files.keys[0]) == '19700101-example_author-doc-test_subject-cno1111111-some_keywords.pdf' and
  `tail -n 1 #{TMPDIR}/pdfmd.log | wc -l`.to_i == 1
  result = 'OK'
else
  puts File.basename(files.keys[0])
  result = 'failed'
end
$testResults.store('006', {:result => result, :command => commandparameter })

