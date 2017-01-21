# spec/pdfmdshow_spec.rb
require 'pdfmd'
require 'pdfmd/pdfmdshow'

RSpec.describe Pdfmdshow do

  before(:all) do
    @@metadata = { 'author' => 'John Doe', 'subject' => 'Invoice', 'title' => '999999', 'createdate' => '1970:01:01 00:00:01', 'keywords' => 'Customernumber 12345' }
    @filename = 'example.pdf'
  end

  it 'is correcting the createdate hash from exif data with colons' do
    correct_date = Pdfmdshow.new
    date_input = { 'createdate' => '1970:01:01' }
    date_output = { 'createdate' => '1970-01-01' }
    expect(correct_date.show_corrected_date_format(date_input)).to eq date_output 
  end


  it 'outputs the metainformation for the author in yaml' do
    metaoutput = Pdfmdshow.new
    options = Hash.new
    options[:tag] = ['author']
    options[:format] = 'yaml'
    options[:includepdf] = false
    expect(metaoutput.show_metatags(options)).to eq "---\nauthor: John Doe\n"
  end

  it 'outputs the metainformation for the subject in csv' do
    metaoutput = Pdfmdshow.new
    options = Hash.new
    options[:tag] = ['subject', 'title']
    options[:format] = 'csv'
    options[:includepdf] = false
    expect(metaoutput.show_metatags(options)).to eq "\"Invoice\",\"999999\""
  end

end
