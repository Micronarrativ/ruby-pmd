term  = ENV.fetch('PDFMD_EXPLAIN')
pdfmd = ENV.fetch('PDFMD')

case term
when ''
  puts 'Available subjects:'
  puts '- author'
  puts '- csv'
  puts '- createdate'
  puts '- hiera'
  puts '- keywords'
  puts '- subject'
  puts '- title'
  puts ' '
  puts "Run `$ #{pdfmd} explain <subject>` to get more details."
else
  # This reads the explain.x.md file relatively to the installed script file
  puts File.read(File.join(File.dirname(__FILE__),"explain.#{term.downcase}.md"))
end
