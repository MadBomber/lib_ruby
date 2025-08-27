#!/usr/bin/env ruby

require_relative '../jaccard_similarity'

puts "=== Jaccard String Similarity Demo ==="
puts

# Character-based similarity examples
puts "Character-based Similarity:"
puts "-" * 30

test_pairs = [
  ["hello", "jello"],
  ["programming", "programming"],
  ["ruby", "python"],
  ["test", "TEST"],
  ["", ""],
  ["abc", ""]
]

test_pairs.each do |str1, str2|
  similarity = JaccardSimilarity.character_similarity(str1, str2)
  puts "#{str1.inspect} <-> #{str2.inspect}: #{similarity.round(3)}"
end

puts "\nCase sensitive vs insensitive:"
puts "Hello <-> hello (case insensitive): #{JaccardSimilarity.character_similarity('Hello', 'hello', case_sensitive: false).round(3)}"
puts "Hello <-> hello (case sensitive):   #{JaccardSimilarity.character_similarity('Hello', 'hello', case_sensitive: true).round(3)}"

# Word-based similarity examples
puts "\n" + "=" * 50
puts "Word-based Similarity:"
puts "-" * 30

word_pairs = [
  ["hello world", "hello universe"],
  ["ruby programming language", "python programming language"],
  ["the quick brown fox", "the lazy brown dog"],
  ["hello world", "world hello"],
  ["", "empty string test"]
]

word_pairs.each do |str1, str2|
  similarity = JaccardSimilarity.word_similarity(str1, str2)
  puts "#{str1.inspect} <-> #{str2.inspect}: #{similarity.round(3)}"
end

# N-gram similarity examples
puts "\n" + "=" * 50
puts "N-gram Similarity (bigrams):"
puts "-" * 30

ngram_pairs = [
  ["testing", "texting"],
  ["similar", "similarity"],
  ["hello", "jello"],
  ["programming", "programs"],
  ["ruby", "rubi"]
]

ngram_pairs.each do |str1, str2|
  similarity = JaccardSimilarity.ngram_similarity(str1, str2, n: 2)
  puts "#{str1.inspect} <-> #{str2.inspect}: #{similarity.round(3)}"
end

# Finding similar strings
puts "\n" + "=" * 50
puts "Finding Similar Strings:"
puts "-" * 30

target = "programming"
candidates = ["programing", "programs", "coding", "development", "program", "scripting"]

puts "Target: #{target.inspect}"
puts "Candidates: #{candidates.inspect}"
puts

results = JaccardSimilarity.find_similar(target, candidates, method: :character, threshold: 0.3)
puts "Character similarity results (threshold: 0.3):"
results.each do |result|
  puts "  #{result[:string].inspect}: #{result[:similarity].round(3)}"
end

# Similarity matrix
puts "\n" + "=" * 50
puts "Similarity Matrix:"
puts "-" * 30

strings = ["cat", "bat", "rat", "dog"]
matrix = JaccardSimilarity.similarity_matrix(strings, method: :character)

print "     "
strings.each { |s| print "#{s.ljust(6)}" }
puts

strings.each_with_index do |str, i|
  print "#{str.ljust(4)} "
  matrix[i].each do |similarity|
    print "#{similarity.round(2).to_s.ljust(6)}"
  end
  puts
end

# Comparison of different methods
puts "\n" + "=" * 50
puts "Method Comparison:"
puts "-" * 30

str1, str2 = "hello world", "hello universe"
puts "Comparing: #{str1.inspect} <-> #{str2.inspect}"
puts

char_sim = JaccardSimilarity.character_similarity(str1, str2)
word_sim = JaccardSimilarity.word_similarity(str1, str2)
ngram_sim = JaccardSimilarity.ngram_similarity(str1, str2, n: 2)

puts "Character similarity: #{char_sim.round(3)}"
puts "Word similarity:      #{word_sim.round(3)}"
puts "Bigram similarity:    #{ngram_sim.round(3)}"

puts "\nDifferent methods emphasize different aspects:"
puts "- Character: focuses on individual character overlap"
puts "- Word: focuses on complete word matches"
puts "- N-gram: focuses on substring patterns"