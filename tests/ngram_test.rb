#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../ngram'

class NgramTest < Minitest::Test

  def test_bigrams_simple_sentence
    ngram = Ngram.new("the quick brown fox")
    bigrams = ngram.ngrams(2)
    expected = [["the", "quick"], ["quick", "brown"], ["brown", "fox"]]
    assert_equal expected, bigrams
  end

  def test_trigrams_simple_sentence  
    ngram = Ngram.new("the quick brown fox jumps")
    trigrams = ngram.ngrams(3)
    expected = [["the", "quick", "brown"], ["quick", "brown", "fox"], ["brown", "fox", "jumps"]]
    assert_equal expected, trigrams
  end

  def test_unigrams
    ngram = Ngram.new("hello world")
    unigrams = ngram.ngrams(1)
    expected = [["hello"], ["world"]]
    assert_equal expected, unigrams
  end

  def test_fourgrams
    ngram = Ngram.new("one two three four five")
    fourgrams = ngram.ngrams(4)
    expected = [["one", "two", "three", "four"], ["two", "three", "four", "five"]]
    assert_equal expected, fourgrams
  end

  def test_empty_string
    ngram = Ngram.new("")
    bigrams = ngram.ngrams(2)
    expected = []
    assert_equal expected, bigrams
  end

  def test_single_word
    ngram = Ngram.new("hello")
    bigrams = ngram.ngrams(2)
    expected = []
    assert_equal expected, bigrams
  end

  def test_two_words_bigram
    ngram = Ngram.new("hello world")
    bigrams = ngram.ngrams(2)
    expected = [["hello", "world"]]
    assert_equal expected, bigrams
  end

  def test_n_larger_than_word_count
    ngram = Ngram.new("one two")
    trigrams = ngram.ngrams(3)
    expected = []
    assert_equal expected, trigrams
  end

  def test_multiple_spaces_handled
    ngram = Ngram.new("hello    world    test")
    bigrams = ngram.ngrams(2)
    expected = [["hello", "world"], ["world", "test"]]
    assert_equal expected, bigrams
  end

  def test_leading_trailing_spaces
    ngram = Ngram.new("  hello world  ")
    bigrams = ngram.ngrams(2)
    expected = [["hello", "world"]]
    assert_equal expected, bigrams
  end

  def test_punctuation_preserved
    ngram = Ngram.new("hello, world! How are you?")
    bigrams = ngram.ngrams(2)
    expected = [["hello,", "world!"], ["world!", "How"], ["How", "are"], ["are", "you?"]]
    assert_equal expected, bigrams
  end

  def test_numbers_in_text
    ngram = Ngram.new("I have 2 cats and 3 dogs")
    trigrams = ngram.ngrams(3)
    expected = [
      ["I", "have", "2"], 
      ["have", "2", "cats"], 
      ["2", "cats", "and"], 
      ["cats", "and", "3"], 
      ["and", "3", "dogs"]
    ]
    assert_equal expected, trigrams
  end

  def test_case_sensitivity
    ngram = Ngram.new("Hello WORLD hello world")
    bigrams = ngram.ngrams(2)
    expected = [["Hello", "WORLD"], ["WORLD", "hello"], ["hello", "world"]]
    assert_equal expected, bigrams
  end

  def test_immutable_input
    input_string = "hello world test"
    ngram = Ngram.new(input_string)
    ngram.ngrams(2)
    assert_equal "hello world test", input_string
  end

  def test_different_n_values_same_instance
    ngram = Ngram.new("one two three four five")
    
    unigrams = ngram.ngrams(1)
    bigrams = ngram.ngrams(2)
    trigrams = ngram.ngrams(3)
    
    assert_equal 5, unigrams.length
    assert_equal 4, bigrams.length 
    assert_equal 3, trigrams.length
  end

end