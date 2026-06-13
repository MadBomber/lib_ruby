require 'minitest/autorun'
require_relative '../trie'

class TrieNodeTest < Minitest::Test
  def setup
    @root = TrieNode.new("")
  end

  def test_char_of_node
    node = TrieNode.new("x")
    assert_equal "x", node.charOfNode
  end

  def test_new_node_cannot_end
    refute @root.canEnd
  end

  def test_search_empty_trie_returns_false
    refute @root.search("anything")
  end

  def test_append_and_search_single_word
    @root.append("apple")
    assert @root.search("apple")
  end

  def test_search_prefix_only_returns_false
    @root.append("apple")
    refute @root.search("app")
  end

  def test_search_missing_word_returns_false
    @root.append("apple")
    refute @root.search("banana")
  end

  def test_append_prefix_then_search_both
    @root.append("app")
    @root.append("apple")
    assert @root.search("app")
    assert @root.search("apple")
  end

  def test_shared_prefix_words
    @root.append("cat")
    @root.append("car")
    assert @root.search("cat")
    assert @root.search("car")
    refute @root.search("ca")
    refute @root.search("cab")
  end

  def test_multiple_words_no_common_prefix
    %w[aiueo aijin aiko aij au tu].each { |w| @root.append(w) }
    assert @root.search("aiueo")
    assert @root.search("aijin")
    assert @root.search("aiko")
    assert @root.search("aij")
    assert @root.search("au")
    assert @root.search("tu")
    refute @root.search("aijo")
    refute @root.search("ai")
  end

  def test_single_character_word
    @root.append("a")
    assert @root.search("a")
    refute @root.search("ab")
  end

  def test_search_empty_string_after_append
    @root.append("")
    assert @root.canEnd
  end
end
