# spec/pdfmdstat_spec.rb
require 'pdfmd/pdfmdstat'

RSpec.describe Pdfmdstat do

  describe '#count_values' do

    expect(Pdfmdstat.new.count_values('', '')).should be 2

  end

end
