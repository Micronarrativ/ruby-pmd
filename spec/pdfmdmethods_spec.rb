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

  describe '#validateDate' do

    #
    # Datestring without separator
    # 
    context 'with a valid date without separators and without timestamp' do
      it 'returns the separated date with an added timestamp of 00:00:00' do
        expect(Pdfmdmethods.validateDate('19700112')).to eq '1970:01:12 00:00:00'
      end
    end

    context 'with a valid american date without separators and without timestamp' do
      it 'returns the separated date in YYYY:mm:dd with an added timestamp of 00:00:00' do
        expect(Pdfmdmethods.validateDate('19701401')).to eq '1970:01:14 00:00:00'
      end
    end

    context 'with a valid american date with a timestamp and without separators' do
      it 'returns the separated date in YYYY:mm:dd' do
        expect(Pdfmdmethods.validateDate('19701401145600')).to eq '1970:01:14 14:56:00'
      end
    end

    context 'with a valid date with timestamp and without separators' do
      it 'returs the separated date and timetstamp' do
        expect(Pdfmdmethods.validateDate('19700112150000')).to eq '1970:01:12 15:00:00'
      end
    end

    context 'with an invalid date without separators and without timestamp' do
      it 'determines the date string as invalid' do
        expect(Pdfmdmethods.validateDate('19701242')).to eq false 
      end
    end

    context 'with a valid date and invalid timestamp and without separators' do
      it 'determines the date string as invalid' do
        expect(Pdfmdmethods.validateDate('19701212250000')).to eq false 
      end
    end

    #
    # Datestring with separators
    #
    #
    # date without timestamp
    context 'with a valid date without a timestamp' do
      it 'returns the date with an added timestamp of 00:00:00' do
        expect(Pdfmdmethods.validateDate('1970:01:12')).to eq '1970:01:12 00:00:00'
        expect(Pdfmdmethods.validateDate('1970-01-12')).to eq '1970:01:12 00:00:00'
      end
    end

    context 'with an invalid date without a timestamp' do
      it 'determines the datestring as invalid' do
        expect(Pdfmdmethods.validateDate('1970:01:35')).to eq false
        expect(Pdfmdmethods.validateDate('1970-01-35')).to eq false
      end
    end

    # date with timestamp
    context 'with a valid date and a timestamp' do
      it 'returns the date with the timestamp' do
        expect(Pdfmdmethods.validateDate('1970:01:12 15:03:46')).to eq '1970:01:12 15:03:46'
        expect(Pdfmdmethods.validateDate('1970-01-12 15:03:46')).to eq '1970:01:12 15:03:46'
      end
    end

    context 'with a valid date and an invalid timestamp' do
      it 'determines the datestring as invalid' do
        expect(Pdfmdmethods.validateDate('1970:01:12 15:03:61')).to eq false
        expect(Pdfmdmethods.validateDate('1970-01-12 15:03:61')).to eq false
      end
    end

    context 'with an invalid date and a valid timestamp' do
      it 'determines the datestring as invalid' do
        expect(Pdfmdmethods.validateDate('1970:01:32 15:03:51')).to eq false
        expect(Pdfmdmethods.validateDate('1970-13-35 15:03:51')).to eq false
      end
    end

    context 'with an invalid date and an invalid timestamp' do
      it 'determines the datestring as invalid' do
        expect(Pdfmdmethods.validateDate('1970:01:32 15:03:61')).to eq false
        expect(Pdfmdmethods.validateDate('1970-13-35 15:03:61')).to eq false
      end
    end

    # american date without timestamp
    context 'with a valid american date' do
      it 'fixes the layout to yyyddmm and adds a zero timestamp' do
        expect(Pdfmdmethods.validateDate('1970:28:12')).to eq '1970:12:28 00:00:00'
        expect(Pdfmdmethods.validateDate('1970-28-12')).to eq '1970:12:28 00:00:00'
      end
    end

    context 'with an invalid american date' do
      it 'determines the datestring as invalid' do
        expect(Pdfmdmethods.validateDate('1970:28:13')).to eq false
      end
    end

    # american date with timestamp
    context 'with an american date and a valid timestamp' do
      it 'fixes the layout yyyyddmm to yyyymmdd' do
        expect(Pdfmdmethods.validateDate('1970:28:12 00:00:01')).to eq '1970:12:28 00:00:01'
        expect(Pdfmdmethods.validateDate('1970-28-12 00:00:01')).to eq '1970:12:28 00:00:01'
      end
    end

    context 'with an american date and a invalid timestamp' do
      it 'determines the datestring as invalid' do
        expect(Pdfmdmethods.validateDate('1970-28-12 00:71:01')).to eq false
        expect(Pdfmdmethods.validateDate('1970-28-12 00:71:01')).to eq false
      end
    end

    context 'with an invalid american date and a valid timestamp' do
      it 'determines the datestring as invalid' do
        expect(Pdfmdmethods.validateDate('1970-32-12 00:51:01')).to eq false
        expect(Pdfmdmethods.validateDate('1970-32-12 00:51:01')).to eq false
      end
    end

    context 'with an invalid american date and an invalid timestamp' do
      it 'determines the datestring as invalid' do
        expect(Pdfmdmethods.validateDate('1970-41-12 00:71:01')).to eq false
        expect(Pdfmdmethods.validateDate('1970-41-12 00:71:01')).to eq false
      end
    end

    context 'with an american date and an invalid timestamp' do
      it 'determines the date string as invalid' do
        expect(Pdfmdmethods.validateDate('1970:28:12 25:00:01')).to eq false 
        expect(Pdfmdmethods.validateDate('1970-28-12 25:00:01')).to eq false 
      end
    end

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
