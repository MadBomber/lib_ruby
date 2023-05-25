# ~/lib/ruby/quick.rb

#######################################################
# Quick benchmarking
# Based on rue's irbrc => http://pastie.org/179534
#
# Can be used like this for the default 100 executions:
#
#       quick { rand }
#
# Or like this for more:
#
#     quick(10000) { rand }
#
def quick(repetitions=100, label="default", &block)
  require 'benchmark'

  # Benchmark.bmbm do |b|
  results = 
  Benchmark.measure(label) do |b|
    repetitions.times &block
  end

  results
end
