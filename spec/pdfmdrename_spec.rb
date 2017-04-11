# spec: pdfmdrename_spec.rb
#
require 'pdfmd'
require 'pdfmd/pdfmdrename'
require 'i18n'

RSpec.describe Pdfmdrename do

  before(:all) do
    @@metadata = {
      'createdate' => '1970:01:01 00:00:01',
      'title'      => 'Information',
      'subject'    => 'Example Subject',
      'author'     => 'John Doe',
      'keywords'   => 'Empty document',
    }
  end

  describe '#rename' do

    context 'intelligently handle strings' do

      it 'determines the author' do
        @@metadata = {
          'createdate' => '1970:01:01 00:00:01',
          'title'      => 'Information',
          'subject'    => 'Example Subject',
          'author'     => 'John Doe',
          'keywords'   => 'Empty document',
        }
        rename_doc = Pdfmdrename.new
        rename_doc.instance_variable_set(:@filename, '/tmp/example.pdf')
        rename_doc.rename
        expect(rename_doc).to receive(:get_author).with(no_args)
      end

      #it 'creates a string for keywords' do
      #  @@metadata = {
      #    'createdate' => '1970:01:01 00:00:01',
      #    'title'      => 'Manual',
      #    'subject'    => 'Some fancy new toy',
      #    'author'     => 'John Doe',
      #    'keywords'   => 'Empty document',
      #  }
      #  rename_doc = Pdfmdrename.new
      #  rename_doc.instance_variable_set(:@filename, '/tmp/example.pdf')
      #  expect(rename_doc).to receive(:get_keywords).with('').and_return('empty_documents')

      #end

    end

    context 'generate filename from metadata' do

      it 'generates a filename for an information document' do
        @@metadata = {
          'createdate' => '1970:01:01 00:00:01',
          'title'      => 'Information',
          'subject'    => 'Example Subject',
          'author'     => 'John Doe',
          'keywords'   => 'Empty document',
        }
        rename_doc = Pdfmdrename.new
        rename_doc.instance_variable_set(:@filename, '/tmp/example.pdf')
        new_file = '/tmp/19700101-john_doe-inf-example_subject-empty_document.pdf' + "\n"
        expect{ rename_doc.rename }.to output('new file: ' + new_file).to_stdout
        expect(rename_doc.filetarget).to eq '/tmp/19700101-john_doe-inf-example_subject-empty_document.pdf'
      end

      it 'generates a filename for a manual document' do
        @@metadata = {
          'createdate' => '1970:01:01 00:00:01',
          'title'      => 'Manual',
          'subject'    => 'Some fancy new toy',
          'author'     => 'John Doe',
          'keywords'   => 'Empty document',
        }
        new_file = "/tmp/19700101-john_doe-man-some_fancy_new_toy-empty_document.pdf"
        rename_doc = Pdfmdrename.new
        rename_doc.instance_variable_set(:@filename, '/tmp/example.pdf')
        expect{rename_doc.rename}.to output('new file: ' + new_file + "\n").to_stdout
        expect(rename_doc.filetarget).to eq new_file
      end

      it 'generates a filename for an invoice' do
        @@metadata = {
          'createdate' => '1970:01:01 00:00:01',
          'title'      => 'Invoice',
          'subject'    => '44381A38',
          'author'     => 'John Doe',
          'keywords'   => 'Empty document',
        }
        new_file = "/tmp/19700101-john_doe-inv-44381a38-empty_document.pdf"
        rename_doc = Pdfmdrename.new
        rename_doc.instance_variable_set(:@filename, '/tmp/example.pdf')
        expect{rename_doc.rename}.to output('new file: ' + new_file + "\n").to_stdout
        expect(rename_doc.filetarget).to eq new_file
      end

      it 'generates a filename for an invoice with a customernumber in the keywords' do
        @@metadata = {
          'createdate' => '1970:01:01 00:00:01',
          'title'      => 'Invoice',
          'subject'    => '44381A38',
          'author'     => 'John Doe',
          'keywords'   => 'Customernumber 987654, Empty document',
        }
        new_file = "/tmp/19700101-john_doe-inv-44381a38-cno987654-empty_document.pdf"
        rename_doc = Pdfmdrename.new
        rename_doc.instance_variable_set(:@filename, '/tmp/example.pdf')
        expect{rename_doc.rename}.to output('new file: ' + new_file + "\n").to_stdout
        expect(rename_doc.filetarget).to eq new_file
      end

      it 'generates a filename with an ampersand in the keywords' do
        @@metadata = {
          'createdate' => '1970:01:01 00:00:01',
          'title'      => 'Invoice',
          'subject'    => '44381A38',
          'author'     => 'John Doe',
          'keywords'   => 'Good & Ugly',
        }
        new_file = "/tmp/19700101-john_doe-inv-44381a38-cno987654-good_ugly.pdf"
        rename_doc = Pdfmdrename.new
        rename_doc.instance_variable_set(:@filename, '/tmp/example.pdf')
        expect{rename_doc.rename}.to output('new file: ' + new_file + "\n").to_stdout
        expect(rename_doc.filetarget).to eq new_file
      end



    end

  end


end

