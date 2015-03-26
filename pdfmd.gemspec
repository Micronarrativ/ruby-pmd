Gem::Specification.new do |s|
  s.name                  = 'pdfmd'
  s.version               = '1.5.0'
  s.date                  = Time.now.strftime("%Y-%m-%d").to_s
  s.summary               = "pdfmd - pdf-meta-data management"
  s.description           = <<-EOF
    Managing the common pdf metadata values and renaming the pdf file accordingly.
    Sets common tags like 'author', 'createdate', 'title', 'subject' and 'keywords'
    and re-uses them for renaming the file with to a human-readable identifier.
  EOF
  s.post_install_message  = 'Run `pdfmd` to see the command help.'
  s.authors               = ['Daniel Roos']
  s.email                 = 'pdfmd@micronarrativ.org'
  s.require_paths         = ['lib']
  s.requirements          << '[exiftools](http://www.sno.phy.queensu.ca/~phil/exiftool/)'
  s.files                 = `git ls-files`.split("\n")
  s.executable            = 'pdfmd'
  s.homepage              = 'https://github.com/Micronarrativ/ruby-pmd'
  s.license               = 'MIT'
  s.add_dependency "thor", '>= 0.19.1'
  s.add_dependency 'highline', '>= 1.7.1'
  s.add_dependency 'fileutils', '>= 0.7'
  s.add_dependency 'i18n', '>= 0.6.11'
end
