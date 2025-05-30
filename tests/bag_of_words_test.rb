# ~/lib/ruby/tests/bag_of_words_test.rb

require 'minitest/autorun'
require_relative '../bag_of_words'

class BagOfWordsTest < Minitest::Test
  def setup
    @bag = BagOfWords.new(stopwords: :en, stem: false)
  end

  def test_initialization
    assert_equal 0, @bag.term_index.size
    assert_equal 0, @bag.doc_count
    assert_instance_of Hash, @bag.doc_frequency
  end

  def test_add_doc_increments_doc_count
    @bag.add_doc("This is a simple test document.")
    assert_equal 1, @bag.doc_count
  end

  def test_terms_count
    @bag.add_doc("Another test document.")
    assert_equal 4, @bag.terms_count # "another", "test", "document"
  end

  def test_add_docs_increments_doc_count
    @bag.add_docs(["First document.", "Second document."])
    assert_equal 2, @bag.doc_count
  end
    
  def test_doc_hashes
    @bag.add_doc("Test the document hash.")
    doc_hash = @bag.doc_hashes.first

    assert_instance_of Hash, doc_hash
    assert doc_hash.key?(@bag.term_index["test"])
  end

  def test_terms_normalization
    @bag.add_doc("Term frequency normalization test.")
    doc_hash = @bag.doc_hashes.first

    assert_in_delta 1.0, doc_hash[@bag.term_index["term"]], 0.01
    assert_in_delta 0.447, doc_hash[@bag.term_index["frequency"]], 0.01
    assert_in_delta 0.447, doc_hash[@bag.term_index["normalization"]], 0.01
  end

  def test_idf_weighting
    @bag.add_docs(["The quick brown fox", "jumps over the lazy dog", "The quick brown dog"])
    @bag.to_a  # This will trigger IDF weighting if enabled

    assert @bag.doc_hashes.all? { |doc| !doc.empty? }
  end

  def test_doc_frequency_updates
    @bag.add_docs(["Word one", "Word two", "Word one"])
    assert_equal 2, @bag.doc_frequency[@bag.term_index["word"]]
  end
end
