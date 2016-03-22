require 'minitest/autorun'
require './prime_generator'

describe PrimeGenerator do
  describe '#perform' do
    it 'should produce a prime multiplication table' do
      expected = <<TEXT
     2   3   5   7  11  13  17  19  23  29
 2   4   6  10  14  22  26  34  38  46  58
 3   6   9  15  21  33  39  51  57  69  87
 5  10  15  25  35  55  65  85  95 115 145
 7  14  21  35  49  77  91 119 133 161 203
11  22  33  55  77 121 143 187 209 253 319
13  26  39  65  91 143 169 221 247 299 377
17  34  51  85 119 187 221 289 323 391 493
19  38  57  95 133 209 247 323 361 437 551
23  46  69 115 161 253 299 391 437 529 667
29  58  87 145 203 319 377 493 551 667 841
TEXT
      -> { PrimeGenerator.new.perform(10) }.must_output(expected)
    end
  end

  describe '#first_n_prime_numbers' do
    it 'returns [2] when 1 number is requested' do
      PrimeGenerator.new.first_n_prime_numbers(1).must_equal [2]
    end

    it 'returns [2, 3] when 2 numbers are requested' do
      PrimeGenerator.new.first_n_prime_numbers(2).must_equal [2, 3]
    end

    it 'returns [2, 3, 5] when 3 numbers are requested' do
      PrimeGenerator.new.first_n_prime_numbers(3).must_equal [2, 3, 5]
    end

    it 'returns [2, 3, 5, 7] when 4 numbers are requested' do
      PrimeGenerator.new.first_n_prime_numbers(4).must_equal [2, 3, 5, 7]
    end

    it 'returns [2, 3, 5, 7, 11, 13, 17, 19, 23, 29] when 10 numbers are requested' do
      PrimeGenerator.new.first_n_prime_numbers(10).must_equal [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    end
  end

  describe '#prime?' do
    it 'is true when value is 2' do
      PrimeGenerator.new.prime?(2).must_equal true
    end

    it 'is true when value is 3' do
      PrimeGenerator.new.prime?(3).must_equal true
    end

    it 'is false when value is 4' do
      PrimeGenerator.new.prime?(4).must_equal false
    end

    it 'is true when value is 5' do
      PrimeGenerator.new.prime?(5).must_equal true
    end

    it 'is false when value is 6' do
      PrimeGenerator.new.prime?(6).must_equal false
    end

    it 'is true when value is 7' do
      PrimeGenerator.new.prime?(7).must_equal true
    end
  end
end