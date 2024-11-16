# ~/test/text_cleaner_test.rb

require 'minitest/autorun'
require_relative '../text_cleaner'

class TextCleanerTest < Minitest::Test
  def setup
    # Create a temporary file for stop words
    @stop_words_file = 'stop_words.txt'
    File.write(@stop_words_file, "and\nor\nthe\nis\n")
    @cleaner = TextCleaner.new(stop_words_file_path: @stop_words_file)
  end

  def teardown
    # Clean up the stop words file after tests
    File.delete(@stop_words_file) if File.exist?(@stop_words_file)
  end

  def test_initialize_with_valid_file
    assert_instance_of TextCleaner, @cleaner
  end

  def test_initialize_with_invalid_file
    assert_raises(ArgumentError) do
      TextCleaner.new(stop_words_file_path: 'invalid_path.txt')
    end
  end

  def test_clean_removes_stop_words
    text = "The quick brown fox jumps over the lazy dog"
    cleaned_text = @cleaner.clean(text)
    # SMELL: weird stemmer change of lazy to lazi
    assert_equal "quick brown fox jump over lazi dog", cleaned_text
  end

  def test_clean_normalizes_text
    text = "The money is $1,234.56!"
    cleaned_text = @cleaner.clean(text)
    assert_equal "money 123456", cleaned_text
  end

  def test_empty_input
    text = ""
    cleaned_text = @cleaner.clean(text)
    assert_equal "", cleaned_text
  end

  def test_only_stop_words
    text = "The and or the"
    cleaned_text = @cleaner.clean(text)
    assert_equal "", cleaned_text
  end
end

