# Print multiplication table of n prime numbers
# $ ruby prime_generator.rb [n]
# defaults to 10
class PrimeGenerator
  def initialize
    @known_primes = []
  end

  def perform(number_of_primes)
    prime_numbers = first_n_prime_numbers(number_of_primes)
    print '  '
    prime_numbers.each do |column_prime|
      print ' %3d' % [column_prime]
    end
    puts

    prime_numbers.each do |row_prime|
      print '%2d' % [row_prime]
      prime_numbers.each do |column_prime|
        print ' %3d' % [row_prime * column_prime]
      end
      puts
    end
  end

  def self.perform(number_of_primes)
    PrimeGenerator.new.perform(number_of_primes)
  end

  def first_n_prime_numbers(number_of_primes)
    primes = []
    possible_prime = 2
    while primes.size < number_of_primes do
      while !prime?(possible_prime)
        possible_prime += 1
      end
      primes << possible_prime
      possible_prime += 1
    end
    primes
  end

  def prime?(possible_prime)
    raise "prime numbers must be greater than 1" if possible_prime <= 1
    @known_primes.each do |n|
      return false if (possible_prime % n) == 0
    end
    first_number_to_test = @known_primes.empty? ? 2 : @known_primes.last + 1
    (first_number_to_test).upto(possible_prime / 2) do |n|
      return false if (possible_prime % n) == 0
    end
    @known_primes << possible_prime
    true
  end
end

if __FILE__ == $0
  number_of_primes = ARGV[0].to_i || 10
  PrimeGenerator.new.perform(number_of_primes)
end