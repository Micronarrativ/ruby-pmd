# Test file for pdfmd.rb
require "pdfmd"
RSpec.describe Pdfmd do

  describe '#check_metatags' do
    it 'checks if value is empty' do
      expect(Pdfmd.check_metatags('string1 string2')).to be true
    end
  end

  
end
