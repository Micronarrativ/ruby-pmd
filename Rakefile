require 'rake'
require 'tmpdir'
require 'fileutils'

TMPDIR      = Dir.mktmpdir
EXAMPLEPDF  = './test/test_default.pdf'
TARGETPDF   = TMPDIR + '/' + File.basename(EXAMPLEPDF)
PDFMD       = './lib/pdfmd.rb'
$testResults = Hash.new

desc 'test pdfmd'
task :test do
  sections = ARGV.last
  #puts ARGV.last
  #puts sections
  task sections.to_sym do ; end

  case sections
  when 'rename'
    rename
  when 'show'
    show
  when 'sort'
    sort
  else
    show
    rename
    sort
  end

end

#
# init Tmpdir
# Reset the temporary directory into a known state
# 1. Delete the tmp dir
# 2. Create the tmp dir
# 3. copy the default file back into it
def initTmpDir
  FileUtils.rm_rf TMPDIR
  FileUtils.mkdir TMPDIR
  FileUtils.cp(EXAMPLEPDF, TMPDIR + '/')
end

#
# Build a new version
#
desc 'Build new gem file, optionally install it'
task :build, :arg1 do |t, args|

  args.with_defaults(:arg1 => '')

  installoutput = `gem build pdfmd.gemspec`

  if args[:arg1] == 'install'

    installoutput.each_line do |line|

      if line.match(/File\:\s/)
        filename = line.split(': ')
        puts `gem install #{filename[1]}`
      end
    end

  end

end

#
# Testing command 'sort'
#
def sort

  puts "Testing command 'sort'"
  require_relative './test/test_sort.rb'
  
  # Cleanup after Tests
  FileUtils.rm_rf TMPDIR
  showTestResults

end


#
# Testing command 'show'
#
def show

  puts "Testing command 'show'"
  require_relative './test/test_show.rb'
  # Cleanup after Tests
  FileUtils.rm_rf TMPDIR
  showTestResults

end

# Testing command 'rename'
#
def rename

  puts "Testing command 'rename'"
  require_relative './test/test_rename.rb'

  # Cleanup after Tests
  FileUtils.rm_rf TMPDIR
  showTestResults

end # End of Task test rename

################################################################################
# Helper methods
################################################################################

#
# Show the test results
def showTestResults

  $testResults.sort.each do |key,value|
    if value[:result] == 'OK'
      puts 'Test ' + key + ' : ' + value[:result].to_s
    else
      puts 'Test ' + key + ' : ' + value[:result].to_s
      puts '  Command: ' + value[:command].to_s
      exit 1
    end
  end
end

# 
# Read the PDF files in the TMPDIR
def readFilesInDir(targetdir)
  filedata = Hash.new
  files= Dir.glob(targetdir + "/*.pdf")
  files.sort.each do |filename|
    filedata[filename] = readExifData(filename)
  end
  return filedata
end

#
# Read the Exifdata of a given file
def readExifData(filepath)

  exifdata = Hash.new

  exifdatatext = `exiftool #{filepath}`
  exifdatatext.each_line do |line|
    case line
    when /^author.*/i
      exifdata['author'] = line.split(' : ').last.chomp
    when /^title.*/i
      exifdata['title'] = line.split(' : ').last.chomp
    when /^subject.*/i
      exifdata['subject'] = line.split(' : ').last.chomp
    when /^keywords.*/i
      exifdata['keywords'] = line.split(' : ').last.chomp
    when /^Create\ Date.*/i
      exifdata['createdate'] = line.split(' : ').last.chomp
    end
  end
  return exifdata
end

task :default do
  system "rake --tasks"
end



