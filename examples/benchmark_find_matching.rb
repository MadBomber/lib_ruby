#!/usr/bin/env ruby
require 'benchmark'
require 'set'
require_relative 'find_matching_entries'

# Original implementation
def find_matching_entries_original(store, data, limit = 10)
  return [] if data.empty?

  matches   = Hash.new { |hash, key| hash[key] = [] }
  data      = data.map(&:downcase)
  max_count = data.size

  store.each_with_index do |entry, index|
    next if entry.empty?

    match_count = (entry.map(&:downcase) & data).size

    if match_count > 0
      matches[match_count] << { entry: entry, index: index }
      break if match_count == max_count && matches[match_count].size >= limit
    end
  end

  if matches.any?
    max_matches = matches.keys.max
    top_matches = matches[max_matches]
    top_matches.first(limit)
  else
    []
  end
end

# Optimized with Set for O(1) lookups
def find_matching_entries_optimized(store, data, limit = 10)
  return [] if data.empty?

  data_set = data.map(&:downcase).to_set
  max_count = data.size
  
  all_matches = []
  
  store.each_with_index do |entry, index|
    next if entry.empty?
    
    match_count = 0
    entry.each do |item|
      match_count += 1 if data_set.include?(item.downcase)
    end
    
    if match_count > 0
      all_matches << [match_count, index, entry]
      
      if match_count == max_count
        perfect_count = all_matches.count { |m| m[0] == max_count }
        break if perfect_count >= limit
      end
    end
  end
  
  all_matches.sort! { |a, b| b[0] <=> a[0] }
             .first(limit)
             .map { |match| { entry: match[2], index: match[1] } }
end

# Generate test data
def generate_test_data(store_size, entry_size, vocab_size)
  vocab = (1..vocab_size).map { |i| "word#{i}" }
  store = Array.new(store_size) do
    Array.new(rand(1..entry_size)) { vocab.sample }
  end
  [store, vocab.sample(rand(2..10))]
end

puts "=" * 60
puts "Benchmark: find_matching_entries"
puts "=" * 60

# Test correctness first
puts "\n1. CORRECTNESS TEST"
puts "-" * 40
test_store = [
  ["apple", "banana", "cherry"],
  ["banana", "kiwi"],
  ["apple", "banana", "kiwi"],
  ["kiwi", "banana"],
  ["apple", "cherry", "mango"],
  ["banana", "cherry", "kiwi", "mango"]
]
test_data = ["banana", "kiwi"]

original_result = find_matching_entries_original(test_store, test_data, 3)
optimized_result = find_matching_entries_optimized(test_store, test_data, 3)
fast_result = find_matching_entries_fast(test_store, test_data, 3)

puts "Test data: #{test_data.inspect}"
puts "Original result:  #{original_result.inspect}"
puts "Optimized result: #{optimized_result.inspect}"
puts "Fast result:      #{fast_result.inspect}"
puts "All match: #{original_result == optimized_result && original_result == fast_result}"

# Performance benchmarks
puts "\n2. PERFORMANCE BENCHMARKS"
puts "-" * 40

# Small dataset
puts "\nSmall dataset (100 entries, 5-10 items each):"
small_store, small_data = generate_test_data(100, 10, 50)
Benchmark.bm(20) do |x|
  x.report("Original:") { 100.times { find_matching_entries_original(small_store, small_data, 10) } }
  x.report("Optimized:") { 100.times { find_matching_entries_optimized(small_store, small_data, 10) } }
  x.report("Fast:") { 100.times { find_matching_entries_fast(small_store, small_data, 10) } }
end

# Medium dataset
puts "\nMedium dataset (1000 entries, 10-20 items each):"
medium_store, medium_data = generate_test_data(1000, 20, 100)
Benchmark.bm(20) do |x|
  x.report("Original:") { 10.times { find_matching_entries_original(medium_store, medium_data, 10) } }
  x.report("Optimized:") { 10.times { find_matching_entries_optimized(medium_store, medium_data, 10) } }
  x.report("Fast:") { 10.times { find_matching_entries_fast(medium_store, medium_data, 10) } }
end

# Large dataset
puts "\nLarge dataset (5000 entries, 20-30 items each):"
large_store, large_data = generate_test_data(5000, 30, 200)
Benchmark.bm(20) do |x|
  x.report("Original:") { 5.times { find_matching_entries_original(large_store, large_data, 10) } }
  x.report("Optimized:") { 5.times { find_matching_entries_optimized(large_store, large_data, 10) } }
  x.report("Fast:") { 5.times { find_matching_entries_fast(large_store, large_data, 10) } }
end

# Worst case: many partial matches
puts "\nWorst case (many partial matches, 2000 entries):"
worst_store = Array.new(2000) { |i| 
  base = ["common1", "common2", "common3"]
  base + (1..5).map { |j| "unique_#{i}_#{j}" }
}
worst_data = ["common1", "common2", "common3", "rare1", "rare2"]
Benchmark.bm(20) do |x|
  x.report("Original:") { 10.times { find_matching_entries_original(worst_store, worst_data, 10) } }
  x.report("Optimized:") { 10.times { find_matching_entries_optimized(worst_store, worst_data, 10) } }
  x.report("Fast:") { 10.times { find_matching_entries_fast(worst_store, worst_data, 10) } }
end

# Memory allocation comparison
puts "\n3. DETAILED TIMING (single run on large dataset)"
puts "-" * 40
require 'benchmark/memory' if defined?(Benchmark::Memory)

result = nil
original_time = Benchmark.realtime do
  result = find_matching_entries_original(large_store, large_data, 10)
end

optimized_time = Benchmark.realtime do
  result = find_matching_entries_optimized(large_store, large_data, 10)
end

fast_time = Benchmark.realtime do
  result = find_matching_entries_fast(large_store, large_data, 10)
end

puts "Original:  #{(original_time * 1000).round(2)}ms"
puts "Optimized: #{(optimized_time * 1000).round(2)}ms"
puts "Fast:      #{(fast_time * 1000).round(2)}ms"
puts "Fast vs Original speedup: #{(original_time / fast_time).round(2)}x faster"