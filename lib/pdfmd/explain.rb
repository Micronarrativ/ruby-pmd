term  = ENV.fetch('PDFMD_EXPLAIN')
pdfmd = ENV.fetch('PDFMD')

case term
when ''
  puts 'Available subjects:'
  puts '- author'
  puts '- createdate'
  puts '- hiera'
  puts '- keywords'
  puts '- subject'
  puts '- title'
  puts ' '
  puts "Run `$ #{pdfmd} explain <subject>` to get more details."
else
  puts File.read("lib/pdfmd/explain.#{term.downcase}.md")
end
