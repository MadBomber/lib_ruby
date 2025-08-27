#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../refinements_string'

class RefinementsStringTest < Minitest::Test
  # Enable the String refinements for this test
  using Refinements

  def test_how_similar_character_method
    similarity = "hello".how_similar("jello")
    expected = 0.6  # {h,e,l,o} vs {j,e,l,o} = 3/5
    assert_in_delta expected, similarity, 0.001
  end

  def test_how_similar_identical_strings
    assert_equal 1.0, "hello".how_similar("hello")
  end

  def test_how_similar_completely_different
    similarity = "abc".how_similar("xyz")
    assert_equal 0.0, similarity
  end

  def test_how_similar_word_method
    similarity = "hello world".how_similar("hello universe", method: :word)
    expected = 1.0 / 3.0  # intersection: {hello}, union: {hello, world, universe}
    assert_in_delta expected, similarity, 0.001
  end

  def test_how_similar_ngram_method
    similarity = "hello".how_similar("jello", method: :ngram, n: 2)
    expected = 3.0 / 5.0  # bigram overlap
    assert_in_delta expected, similarity, 0.001
  end

  def test_how_similar_case_insensitive
    similarity = "Hello".how_similar("hello", case_sensitive: false)
    assert_equal 1.0, similarity
  end

  def test_how_similar_case_sensitive
    similarity = "Hello".how_similar("hello", case_sensitive: true)
    expected = 3.0 / 5.0  # {H,e,l,o} vs {h,e,l,o} = {e,l,o} / {H,h,e,l,o}
    assert_in_delta expected, similarity, 0.001
  end

  def test_how_similar_invalid_method
    assert_raises ArgumentError do
      "hello".how_similar("world", method: :invalid)
    end
  end

  def test_similar_to_default_threshold
    # Default threshold is 0.5
    assert "hello".similar_to?("jello")     # 0.6 > 0.5
    refute "hello".similar_to?("world")     # low similarity < 0.5
  end

  def test_similar_to_custom_threshold
    assert "hello".similar_to?("jello", threshold: 0.5)
    refute "hello".similar_to?("jello", threshold: 0.7)  # 0.6 < 0.7
  end

  def test_similar_to_threshold_zero
    # Everything should be similar with threshold 0.0
    assert "hello".similar_to?("xyz", threshold: 0.0)
  end

  def test_similar_to_threshold_one
    # Only identical strings should be similar with threshold 1.0
    assert "hello".similar_to?("hello", threshold: 1.0)
    refute "hello".similar_to?("jello", threshold: 1.0)
  end

  def test_similar_to_word_method
    assert "hello world".similar_to?("hello universe", threshold: 0.3, method: :word)
    refute "hello world".similar_to?("goodbye world", threshold: 0.4, method: :word)
  end

  def test_similar_to_ngram_method
    assert "testing".similar_to?("texting", threshold: 0.4, method: :ngram, n: 2)
    refute "testing".similar_to?("random", threshold: 0.4, method: :ngram, n: 2)
  end

  def test_similar_to_with_options
    assert "Hello".similar_to?("hello", threshold: 0.9, case_sensitive: false)
    refute "Hello".similar_to?("hello", threshold: 0.9, case_sensitive: true)
  end

  def test_empty_strings
    assert_equal 1.0, "".how_similar("")
    assert "".similar_to?("", threshold: 1.0)
    assert_equal 0.0, "hello".how_similar("")
    refute "hello".similar_to?("", threshold: 0.1)
  end

  def test_chaining_methods
    # Test that the methods can be chained with other string methods
    result = "HELLO".downcase.how_similar("jello")
    expected = 0.6
    assert_in_delta expected, result, 0.001
    
    assert "HELLO".downcase.similar_to?("jello", threshold: 0.5)
  end

  # Test existing refinement methods still work
  def test_existing_refinements_still_work
    assert_equal "123", "abc123def".to_digits
    assert "123.45".numeric?
    refute "abc".numeric?
  end
end