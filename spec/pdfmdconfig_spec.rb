# spec/pdfmdconfig_spec.rb
require 'pdfmd'
require 'pdfmd/pdfmdconfig'

RSpec.describe Pdfmdconfig do

  before(:all) do
    @@hieradata = {
      'default' => {
        'loglevel' => 'debug',
      },
      'show' => {
        'format' => 'yaml',
        'includepdf' => 'true',
      },
    }
  end

  context 'when asked for the whole configuration' do
    it 'is returning the whole configuration in yaml' do
      config = Pdfmdconfig.new
      expect(config.show_config()).to eq "---\ndefault:\n  loglevel: debug\nshow:\n  format: yaml\n  includepdf: 'true'\n"
    end
  end

  context 'when asked for a specific subsegment (show) for the configuration' do
    it 'is returning the configuration for show in yaml' do
      config = Pdfmdconfig.new
      expect(config.show_config('show')).to eq "---\nformat: yaml\nincludepdf: 'true'\n"
    end
  end

  context 'when asked for an unknown subsegment (test) for the configuration' do
    it 'is raising an error' do
      config = Pdfmdconfig.new
      expect{config.show_config('test') }.to raise_error("Error: Unknown hiera key 'test'. Abort.")
    end
  end

end
