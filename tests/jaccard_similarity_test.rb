#!/usr/bin/env ruby

require 'minitest/autorun'
require 'set'
require_relative '../jaccard_similarity'

class JaccardSimilarityTest < Minitest::Test
  
  def test_basic_jaccard_index
    set1 = Set.new([1, 2, 3])
    set2 = Set.new([2, 3, 4])
    
    similarity = JaccardSimilarity.jaccard_index(set1, set2)
    expected = 2.0 / 4.0  # intersection: {2,3}, union: {1,2,3,4}
    
    assert_in_delta expected, similarity, 0.001
  end

  def test_jaccard_index_identical_sets
    set1 = Set.new(['a', 'b', 'c'])
    set2 = Set.new(['a', 'b', 'c'])
    
    assert_equal 1.0, JaccardSimilarity.jaccard_index(set1, set2)
  end

  def test_jaccard_index_no_overlap
    set1 = Set.new(['a', 'b'])
    set2 = Set.new(['c', 'd'])
    
    assert_equal 0.0, JaccardSimilarity.jaccard_index(set1, set2)
  end

  def test_jaccard_index_empty_sets
    set1 = Set.new
    set2 = Set.new
    
    assert_equal 0.0, JaccardSimilarity.jaccard_index(set1, set2)
  end

  def test_character_similarity_identical_strings
    assert_equal 1.0, JaccardSimilarity.character_similarity("hello", "hello")
  end

  def test_character_similarity_different_strings
    similarity = JaccardSimilarity.character_similarity("hello", "world")
    # hello: {h,e,l,o} world: {w,o,r,l,d}
    # intersection: {l,o}, union: {h,e,l,o,w,r,d}
    expected = 2.0 / 7.0
    
    assert_in_delta expected, similarity, 0.001
  end

  def test_character_similarity_case_insensitive
    similarity = JaccardSimilarity.character_similarity("Hello", "hello", case_sensitive: false)
    assert_equal 1.0, similarity
  end

  def test_character_similarity_case_sensitive
    similarity = JaccardSimilarity.character_similarity("Hello", "hello", case_sensitive: true)
    # Hello: {H,e,l,o} hello: {h,e,l,o}
    # intersection: {e,l,o}, union: {H,h,e,l,o}
    expected = 3.0 / 5.0
    
    assert_in_delta expected, similarity, 0.001
  end

  def test_character_similarity_empty_strings
    assert_equal 1.0, JaccardSimilarity.character_similarity("", "")
    assert_equal 0.0, JaccardSimilarity.character_similarity("hello", "")
    assert_equal 0.0, JaccardSimilarity.character_similarity("", "world")
  end

  def test_word_similarity_identical_strings
    assert_equal 1.0, JaccardSimilarity.word_similarity("hello world", "hello world")
  end

  def test_word_similarity_different_order
    similarity = JaccardSimilarity.word_similarity("hello world", "world hello")
    assert_equal 1.0, similarity  # Same words, different order
  end

  def test_word_similarity_partial_overlap
    similarity = JaccardSimilarity.word_similarity("hello world", "hello universe")
    # intersection: {hello}, union: {hello, world, universe}
    expected = 1.0 / 3.0
    
    assert_in_delta expected, similarity, 0.001
  end

  def test_word_similarity_case_insensitive
    similarity = JaccardSimilarity.word_similarity("Hello World", "hello world", case_sensitive: false)
    assert_equal 1.0, similarity
  end

  def test_word_similarity_case_sensitive
    similarity = JaccardSimilarity.word_similarity("Hello World", "hello world", case_sensitive: true)
    # No common words when case sensitive
    assert_equal 0.0, similarity
  end

  def test_word_similarity_custom_separator
    similarity = JaccardSimilarity.word_similarity("hello,world", "hello,universe", word_separator: /,/)
    expected = 1.0 / 3.0  # intersection: {hello}, union: {hello, world, universe}
    
    assert_in_delta expected, similarity, 0.001
  end

  def test_ngram_similarity_bigrams
    # "hello" bigrams: {he, el, ll, lo}
    # "world" bigrams: {wo, or, rl, ld}
    # No overlap, so similarity = 0
    similarity = JaccardSimilarity.ngram_similarity("hello", "world", n: 2)
    assert_equal 0.0, similarity
  end

  def test_ngram_similarity_bigrams_with_overlap
    # "hello" bigrams: {he, el, ll, lo}
    # "jello" bigrams: {je, el, ll, lo}
    # intersection: {el, ll, lo}, union: {he, el, ll, lo, je}
    similarity = JaccardSimilarity.ngram_similarity("hello", "jello", n: 2)
    expected = 3.0 / 5.0
    
    assert_in_delta expected, similarity, 0.001
  end

  def test_ngram_similarity_trigrams
    similarity = JaccardSimilarity.ngram_similarity("hello", "jello", n: 3)
    # "hello" trigrams: {hel, ell, llo}
    # "jello" trigrams: {jel, ell, llo}
    # intersection: {ell, llo}, union: {hel, ell, llo, jel}
    expected = 2.0 / 4.0
    
    assert_in_delta expected, similarity, 0.001
  end

  def test_ngram_similarity_case_insensitive
    similarity = JaccardSimilarity.ngram_similarity("Hello", "hello", n: 2, case_sensitive: false)
    assert_equal 1.0, similarity
  end

  def test_ngram_similarity_short_strings
    similarity = JaccardSimilarity.ngram_similarity("a", "b", n: 2)
    assert_equal 0.0, similarity  # Strings too short for bigrams
  end

  def test_similarity_matrix
    strings = ["hello", "jello", "world"]
    matrix = JaccardSimilarity.similarity_matrix(strings, method: :character)
    
    # Verify diagonal is all 1.0
    assert_equal 1.0, matrix[0][0]
    assert_equal 1.0, matrix[1][1]
    assert_equal 1.0, matrix[2][2]
    
    # Verify symmetry
    assert_equal matrix[0][1], matrix[1][0]
    assert_equal matrix[0][2], matrix[2][0]
    assert_equal matrix[1][2], matrix[2][1]
    
    # hello vs jello should be high similarity
    assert matrix[0][1] > 0.5
    
    # hello vs world should be lower similarity
    assert matrix[0][2] < 0.5
  end

  def test_find_similar
    target = "hello"
    candidates = ["jello", "world", "help", "yellow"]
    
    results = JaccardSimilarity.find_similar(target, candidates, method: :character)
    
    # Should return all candidates sorted by similarity
    assert_equal 4, results.length
    
    # Results should be sorted by similarity (descending)
    (0...results.length-1).each do |i|
      assert results[i][:similarity] >= results[i+1][:similarity]
    end
    
    # First result should be most similar
    assert_equal "jello", results.first[:string]
  end

  def test_find_similar_with_threshold
    target = "hello"
    candidates = ["jello", "world", "help", "yellow"]
    
    results = JaccardSimilarity.find_similar(target, candidates, method: :character, threshold: 0.3)
    
    # Should filter out results below threshold
    assert results.length < 4
    results.each do |result|
      assert result[:similarity] >= 0.3
    end
  end

  def test_find_similar_word_method
    target = "hello world"
    candidates = ["hello universe", "goodbye world", "hello there", "foo bar"]
    
    results = JaccardSimilarity.find_similar(target, candidates, method: :word)
    
    # "hello universe" should be first (shares "hello")
    assert_equal "hello universe", results.first[:string]
  end

  def test_find_similar_ngram_method
    target = "testing"
    candidates = ["texting", "resting", "nested", "random"]
    
    results = JaccardSimilarity.find_similar(target, candidates, method: :ngram, n: 2)
    
    # "texting" and "resting" should have higher similarity due to shared bigrams
    top_two = results.take(2).map { |r| r[:string] }
    assert_includes top_two, "texting"
    assert_includes top_two, "resting"
  end

  def test_unknown_similarity_method
    assert_raises ArgumentError do
      JaccardSimilarity.similarity_matrix(["a", "b"], method: :unknown)
    end
    
    assert_raises ArgumentError do
      JaccardSimilarity.find_similar("target", ["a", "b"], method: :unknown)
    end
  end
end