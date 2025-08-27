#!/usr/bin/env ruby

require_relative '../refinements_string'

# Enable the String refinements
using Refinements

puts "=== String Similarity Refinement Demo ==="
puts

# Basic how_similar usage
puts "Basic how_similar usage:"
puts "-" * 30
puts '"hello".how_similar("jello") = ' + "hello".how_similar("jello").round(3).to_s
puts '"programming".how_similar("programing") = ' + "programming".how_similar("programing").round(3).to_s
puts '"ruby".how_similar("python") = ' + "ruby".how_similar("python").round(3).to_s
puts

# Different similarity methods
puts "Different similarity methods:"
puts "-" * 30
str1, str2 = "hello world", "hello universe"
puts "Comparing: #{str1.inspect} vs #{str2.inspect}"
puts "Character similarity: " + str1.how_similar(str2, method: :character).round(3).to_s
puts "Word similarity:      " + str1.how_similar(str2, method: :word).round(3).to_s
puts "Bigram similarity:    " + str1.how_similar(str2, method: :ngram, n: 2).round(3).to_s
puts

# similar_to? with default threshold (0.5)
puts "similar_to? with default threshold (0.5):"
puts "-" * 30
test_pairs = [
  ["hello", "jello"],
  ["programming", "programing"], 
  ["ruby", "python"],
  ["test", "TEST"],
  ["similar", "similarity"]
]

test_pairs.each do |str1, str2|
  result = str1.similar_to?(str2)
  similarity = str1.how_similar(str2)
  puts "#{str1.inspect}.similar_to?(#{str2.inspect}) = #{result} (similarity: #{similarity.round(3)})"
end
puts

# similar_to? with custom thresholds
puts "similar_to? with custom thresholds:"
puts "-" * 30
target = "programming"
candidates = ["programing", "programs", "coding", "development"]

candidates.each do |candidate|
  similarity = target.how_similar(candidate)
  puts "#{target.inspect}.similar_to?(#{candidate.inspect}, threshold: 0.3) = #{target.similar_to?(candidate, threshold: 0.3)} (similarity: #{similarity.round(3)})"
end
puts

# Case sensitivity examples
puts "Case sensitivity examples:"
puts "-" * 30
puts '"Hello".how_similar("hello") = ' + "Hello".how_similar("hello").round(3).to_s + " (case insensitive default)"
puts '"Hello".how_similar("hello", case_sensitive: true) = ' + "Hello".how_similar("hello", case_sensitive: true).round(3).to_s + " (case sensitive)"
puts '"Hello".similar_to?("hello", threshold: 0.9) = ' + "Hello".similar_to?("hello", threshold: 0.9).to_s
puts '"Hello".similar_to?("hello", threshold: 0.9, case_sensitive: true) = ' + "Hello".similar_to?("hello", threshold: 0.9, case_sensitive: true).to_s
puts

# Method chaining examples
puts "Method chaining examples:"
puts "-" * 30
puts '"HELLO WORLD".downcase.how_similar("hello universe", method: :word) = ' + "HELLO WORLD".downcase.how_similar("hello universe", method: :word).round(3).to_s
puts '"  hello  ".strip.similar_to?("hello") = ' + "  hello  ".strip.similar_to?("hello").to_s
puts

# Practical examples
puts "Practical examples:"
puts "-" * 30

# Fuzzy string matching
search_term = "programing"  # misspelled
available_options = ["programming", "algorithms", "debugging", "testing", "scripting"]

puts "Fuzzy search for: #{search_term.inspect}"
puts "Available options: #{available_options.inspect}"
puts "Matches with similarity >= 0.6:"

matches = available_options.select { |option| search_term.similar_to?(option, threshold: 0.6) }
matches.each do |match|
  similarity = search_term.how_similar(match)
  puts "  #{match} (similarity: #{similarity.round(3)})"
end

if matches.empty?
  puts "  No matches found with threshold 0.6"
  puts "  Best match: #{available_options.max_by { |opt| search_term.how_similar(opt) }} (similarity: #{available_options.map { |opt| search_term.how_similar(opt) }.max.round(3)})"
end