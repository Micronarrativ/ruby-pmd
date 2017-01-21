# in spec/calculator_spec.rb
require 'calculator'
RSpec.describe Calculator do
  describe '#add' do
    it 'returne the sum of its arguments' do
      expect(Calculator.new.add(1, 2)).to eq(3)
    end
  end
end
