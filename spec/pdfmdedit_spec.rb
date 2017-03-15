# spec/pdfmdedit.rb
require 'pdfmd'
require 'pdfmd/pdfmdedit'

RSpec.describe Pdfmdedit do

  before(:all) do
    @@metadata       = { 'author' => 'John Doe', 'subject' => '999999', 'title' => 'Invoice', 'createdate' => '1970:01:01 00:00:01', 'keywords' => 'Customernumber aaaaaa' }
    @@edit_separator = '='
    @filename        = 'example.pdf'
    @default_tags    = Array.new
  end

  it 'is setting the tags to edit to author and subject' do
    edit_doc = Pdfmdedit.new 
    tags = [ 'author', 'subject' ]
    edit_doc.set_tags tags
    expect(edit_doc.default_tags).to eq ["author","subject"]
  end

  it 'sets the filename variable' do
    edit_doc = Pdfmdedit.new
    edit_doc.filename = 'example.pdf'
    expect(edit_doc.filename).to eq 'example.pdf'
  end

  it 'sets the variable with the tags to edit' do
    edit_doc = Pdfmdedit.new
    tags = [ 'author', 'subject', 'title']
    edit_doc.set_tags tags
    expect(edit_doc.instance_variable_get(:@edit_tags)).to eq({"author" => "", "subject" => "", "title" => ""})
  end

  context 'when given specific tags to edit' do
    it 'sets the variable with the tags to edit for all' do
      edit_doc = Pdfmdedit.new
      tags = 'all'
      edit_doc.set_tags tags
      expect(edit_doc.instance_variable_get(:@edit_tags)).to eq({"author" => "", "subject" => "", "title" => "", "createdate" => "", "keywords" => ""})
    end
  
    it 'sets the variable @edit_tags with two tags and no values' do
      edit_doc = Pdfmdedit.new
      tags = 'Author,subject'
      edit_doc.set_tags tags
      expect(edit_doc.instance_variable_get(:@edit_tags)).to eq({"author" => "", "subject" => ""})
    end
  end

  context 'when given specific tags and values to update' do
    it 'sets the variable @edit_tags with author and subject and two values' do
      edit_doc = Pdfmdedit.new
      tags = "Author='John Doe',subject='Some Invoice'"
      edit_doc.set_tags tags
      expect(edit_doc.instance_variable_get(:@edit_tags)).to eq({"author" => "John Doe", "subject" => "Some Invoice"})
    end
  
    it 'sets the variable @edit_Tags with author and subject, random values, but with apostrophe included' do
      edit_doc = Pdfmdedit.new
      tags = "Author='John\'s Doe',subject='Someone\'s Invoice'"
      edit_doc.set_tags tags
      expect(edit_doc.instance_variable_get(:@edit_tags)).to eq({"author" => "John's Doe", "subject" => "Someone's Invoice"})
    end
  end

  #it 'sets an invalid createdate' do
  #  edit_doc = Pdfmdedit.new
  #  tags = "CreateDate='19701301'"
  #  expect(edit_doc.set_tags(tags)).should raise_error
  #end
 
  context 'when ask to validy a given date string' do 
    it 'sets a valid createdate with a date only' do
      edit_doc = Pdfmdedit.new
      tags = "CreateDate=19700101"
      edit_doc.set_tags tags
      expect(edit_doc.instance_variable_get(:@edit_tags)).to eq({"createdate" => "1970:01:01 00:00:00" })
    end
  
    it 'sets a valid createdate with a date and a time' do
      edit_doc = Pdfmdedit.new
      tags = "CreateDate=19700101180000"
      edit_doc.set_tags tags
      expect(edit_doc.instance_variable_get(:@edit_tags)).to eq({"createdate" => "1970:01:01 18:00:00" })
    end
  
    it 'sets a valid createdate with a date and a time and colon separate' do
      edit_doc = Pdfmdedit.new
      tags = "CreateDate='1970-01-01 18:00:00'"
      edit_doc.set_tags tags
      expect(edit_doc.instance_variable_get(:@edit_tags)).to eq({"createdate" => "1970:01:01 18:00:00" })
    end
  end

  context 'when given specific tags and user interaction is required' do

    it 'updates the tag author from the user' do
      @@metadata       = { 'author' => 'John Doe', 'subject' => '999999', 'title' => 'Invoice', 'createdate' => '1970:01:01 00:00:01', 'keywords' => 'Customernumber aaaaaa' }
      edit_doc = Pdfmdedit.new
      edit_doc.instance_variable_set(:@edit_tags, { 'author' => "" })
      expect(edit_doc).to receive(:readUserInput).with('New value: ').and_return('Jane Doe')
      edit_doc.update_tags
      expect(@@metadata).to eq({
        'author' => 'Jane Doe',
        'subject' => '999999',
        'title' => 'Invoice',
        'createdate' => '1970:01:01 00:00:01',
        'keywords' => 'Customernumber aaaaaa',
      })
    end
  end
  
  it 'updates tags with predefined values' do 
    edit_doc = Pdfmdedit.new
    tags = {
      'author' => 'John Doe',
      'Title' => 'Invoice',
      'Subject' => '123456',
      'keywords' => 'Customernumber 98765',
    }
    edit_doc.instance_variable_set(:@edit_tags, tags)
    edit_doc.update_tags
    expect(@@metadata).to eq({
      'author' => 'John Doe',
      'subject' => '123456',
      'title' => 'Invoice',
      'createdate' => '1970:01:01 00:00:01',
      'keywords' => 'Customernumber 98765',
    })
  end

end
