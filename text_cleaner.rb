# ~/lib/ruby/text_cleaner.rb

# gem ins 'ruby-stemmer'
# The algo traces back to old Snowball days
require 'lingua/stemmer'

# The TextCleaner class cleans text or more precisely
# normalizes text for the purposes of index and search
# operations.  The normalization process includes:
#   - making all text lower case
#   - removing non-alphanumeric + space characters
#   - removing common "stop words" (a, an, and, the etc.)
#     can remove common (shared) corpus or domain words
#   - using root word forms (stemming)
#
class TextCleaner
  
  # The constructor takes a file path to a list of stop words 
  # during initialization. The stop words file is expected 
  # to have one word per line. Additionally, it accepts an 
  # optional array of domain-specific words that are common 
  # within the corpus of material being cleaned.
  #
  # @param stop_words_file_path [String, nil] The file path 
  #        to the stop words file. If nil, no stop words 
  #        will be loaded from a file.
  #
  # @param shared_words [Array<String>, nil] An array of 
  #        domain-specific words to include as stop words. 
  #        If nil, an empty array will be used.
  #
  # @param stemmer [Boolean] Whether to enable stemming 
  #        when cleaning text. Defaults to true.
  #
  # @param language [String] The language for the stemmer, 
  #        which defaults to 'en' (English).
  #
  def initialize(
      stop_words_file_path: nil, 
      shared_words:         nil,
      stemmer:              true,
      language:             'en'
    )
    if stemmer
      @stemmer = Lingua::Stemmer.new(language: language)
    else
      @stemmer = nil
    end

    if shared_words.nil?
      @shared = []
    else
      unless  shared_words.is_a?(Array) && 
              shared_words.all?(String)
        raise "shared_words must be an Array of Strings, got #{shared_words.class}"
      end
      @shared = shared_words
    end

    if stop_words_file_path.nil?
      @stoppers = []
    else
      unless File.exist?(stop_words_file_path) &&
             File.file?(stop_words_file_path) &&
             File.readable?(stop_words_file_path)
        raise ArgumentError, "The provided stop words file path is either invalid, not a file, or not readable."
      end

      @stoppers = File.readlines(stop_words_file_path).map(&:strip)
    end

    @stoppers += @shared
    @stoppers.sort!.uniq!
  end


  # Cleans the provided text by performing the following operations:
  #   - Converts the text to lowercase.
  #   - Removes all non-alphanumeric characters except for spaces.
  #   - Splits the text into individual words.
  #   - Applies stemming to the words if stemming is enabled.
  #   - Removes stop words as defined by the initialized list and any
  #     additional words specified in the `remove` parameter.
  #
  # @param text [String] The input text to clean.
  #
  # @param remove [Array<String>] An array of additional words to remove 
  #                                from the cleaned text.
  #
  # @return [String] The cleaned text with unwanted words removed.
  #
  def clean(text, remove: [])
    words = text
             .downcase
             .gsub(/[^a-z0-9\s]/, '') # SMELL: mangles numbers like money $1,234.56 becomes 123456
             .split

    if @stemmer
      words.map!{ |word| @stemmer.stem(word) }
    end

    (words - @stoppers - remove).join(' ')
  end
end
