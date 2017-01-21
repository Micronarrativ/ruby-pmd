# spec: pdfmdmethods_spec.rb

require 'pdfmd/pdfmdmethods.rb'

RSpec.describe Pdfmdmethods do

  before(:all) do
    @hieradata = {
      'show' => {
        'format' => 'hash',
        'includepdf' => 'true',
      },
    }

  end

  describe '#determineValidSetting' do

    context 'with a manual setting' do

      it 'returns the valid manual setting' do
        manualSetting = 'csv'
        key           = 'show::format'
        expect(Pdfmdmethods).to receive(:log).with('debug',"Chosing manual setting 'show::format = csv'.").and_return('')
        expect(Pdfmdmethods.determineValidSetting(manualSetting,key)).to eq 'csv'

      end
    end

  end

end
