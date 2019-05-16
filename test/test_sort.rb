# Testing the results of the command 'sort'
#
# Test 001
# Testing Abort when running on a single file
# Disabled since single file support in version 1.9.0

# Test 002
# Testing Sorting on a dir
initTmpDir
commandparameter = " sort -d #{TMPDIR}/target "
`#{PDFMD} #{commandparameter} #{TMPDIR}`
files = readFilesInDir(TMPDIR + '/target/example_author')
if files.size == 1 and
  File.basename(files.keys[0]) == 'test_default.pdf'
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('002',{:result => result, :command => commandparameter })

# Test 003
# Testing sorting on a dir with copy instead of moving
initTmpDir
commandparameter = " sort -d #{TMPDIR}/target -c "
`#{PDFMD} #{commandparameter} #{TMPDIR}`
filesTarget = readFilesInDir(TMPDIR + '/target/example_author')
filesSource = readFilesInDir(TMPDIR)
if filesTarget.size == 1 and
  filesSource.size == 1 and
  File.basename(filesTarget.keys[0]) == 'test_default.pdf' and
  File.basename(filesSource.keys[0]) == 'test_default.pdf'
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('003',{:result => result, :command => commandparameter })

# Test 004
# Testing sorting on a dir with dryrun option
initTmpDir
commandparameter = " sort -d #{TMPDIR}/target -n "
`#{PDFMD} #{commandparameter} #{TMPDIR}`
filesTarget = readFilesInDir(TMPDIR + '/target/example_author')
filesSource = readFilesInDir(TMPDIR)
if filesTarget.size == 0 and
  filesSource.size == 1 and
  File.basename(filesSource.keys[0]) == 'test_default.pdf'
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('004',{:result => result, :command => commandparameter })

# Test 005
# Testing sorting on a dir with log creation
# and default log location (changed in this case)
initTmpDir
commandparameter = " sort -d #{TMPDIR}/target -l -p #{TMPDIR}/pdfmd.log"
`#{PDFMD} #{commandparameter} #{TMPDIR}`
filesTarget = readFilesInDir(TMPDIR + '/target/example_author')
filesSource = readFilesInDir(TMPDIR)
if filesTarget.size == 1 and
  filesSource.size == 0 and
  File.basename(filesTarget.keys[0]) == 'test_default.pdf' and
  File.exist?(TMPDIR + '/pdfmd.log')
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('005',{:result => result, :command => commandparameter })

# Test 006
# Testing sorting on a dir without log creation
initTmpDir
commandparameter = " sort -d #{TMPDIR}/target -l false -p #{TMPDIR}/pdfmd.log"
`#{PDFMD} #{commandparameter} #{TMPDIR}`
filesTarget = readFilesInDir(TMPDIR + '/target/example_author')
filesSource = readFilesInDir(TMPDIR)
if filesTarget.size == 1 and
  filesSource.size == 0 and
  File.basename(filesTarget.keys[0]) == 'test_default.pdf' and
  not File.exist?(TMPDIR + '/pdfmd.log')
  result = 'OK'
else
  result = 'failed'
end
$testResults.store('006',{:result => result, :command => commandparameter })

