require 'minitest/autorun'
require 'atv'
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
    it 'generates the requested number of primes' do
      test_data, line_no = <<EOD, __LINE__ + 4
|-----------+---------------------------|
| requested | primes                    |
|-----------+---------------------------|
|         1 | 2                         |
|         2 | 2,3                       |
|         3 | 2,3,5                     |
|         4 | 2,3,5,7                   |
|        10 | 2,3,5,7,11,13,17,19,23,29 |
|-----------+---------------------------|
EOD
      ATV.from_string(test_data).each_with_index do |row, index|
        requested_number = row['requested'].to_i
        expected = row['primes'].split(',').map(&:to_i)
        PrimeGenerator.new.first_n_prime_numbers(requested_number).must_equal expected,
                                                                              %Q|Unexpected primes when #{requested_number} requested at #{__FILE__}:#{line_no+index}|
      end
    end
  end

  describe '#prime?' do
    it 'correctly identifies prime numbers' do
      test_data, line_no = <<EOD, __LINE__ + 4
|--------+--------|
| number | prime? |
|--------+--------|
|      2 | true   |
|      3 | true   |
|      4 | false  |
|      5 | true   |
|      6 | false  |
|      7 | true   |
|--------+--------|
EOD
      ATV.from_string(test_data).each_with_index do |row, index|
        number = row['number'].to_i
        expected = row['prime?']
        PrimeGenerator.new.prime?(number).must_equal expected,
                                                  %Q|#{number} requested at #{__FILE__}:#{line_no+index}|
      end
    end
  end
end
