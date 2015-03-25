Gem::Specification.new do |s|
  s.name        = 'pdfmd'
  s.version     = '1.4.2'
  s.date        = '2015-03-25'
  s.summary     = "pdfmd - pdf-meta-data management"
  s.description = <<-EOF
    Managing the common pdf metadata values and renaming the pdf file accordingly.
    Sets common tags like 'author', 'createdate', 'title', 'subject' and 'keywords'
    and re-uses them for renaming the file with to an human-readable identifier.
  EOF
  s.authors     = ['Daniel Roos']
  s.email       = 'pdfmd@micronarrativ.org'
  s.require_paths = ['lib']
  s.files       = `git ls-files`.split("\n")
  #s.files       = ['lib/pdfmd.rb', 'lib/pdfmd/test.rb', 'lib/pdfmd/sort.rb']
  #s.files       = Dir.glob("{bin,lib}/**/*") + %w(LICENSE README.md CHANGELOG.md)
  #s.executable  = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.executable  = 'pdfmd'
  #s.platform    = Gem::Platform.local
  s.homepage    =
    'https://github.com/Micronarrativ/ruby-pmd'
  s.license       = 'MIT'
  s.add_dependency "thor", '0.19.1'
  s.add_dependency 'highline', '1.7.1'
  s.add_dependency 'fileutils', '0.7'
  s.add_dependency 'i18n', '0.6.11'
end
