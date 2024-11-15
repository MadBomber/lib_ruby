# ~/lib/ruby/text_cleaner.rb

# Fast Porter stemmer based on a C version of the algorithm
# It adds the method String#stem
require 'fast_stemmer'

# The TextCleaner class is responsible for cleaning text 
# input by removing stop words and normalizing the text. 
# It utilizes the `fast_stemmer` gem to stem words and 
# eliminate common stop words from the text for better 
# processing and analysis.
#
# The class takes a file path to a list of stop words 
# during initialization. The stop words file is expected 
# to have one word per line.
#
class TextCleaner
  # The stop words file is expected to have one word per line
  def initialize(stop_words_file_path: nil)
    if stop_words_file_path.nil?
      @stoppers = []
    else
      unless  File.exist?(stop_words_file_path)     && 
              File.file?(stop_words_file_path)      && 
              File.readable?(stop_words_file_path)
        raise ArgumentError, "The provided stop words file path is either invalid, not a file, or not readable."
      end

      @stoppers = File.readlines(stop_words_file_path).map(&:strip)
    end
  end


  def clean(text)
    words = text
             .downcase
             .gsub(/[^a-z0-9\s]/, '') # SMELL: mangles numbers like money $1,234.56 becomes 123456
             .split
             .map(&:stem)

    (words - @stoppers).join(' ')
  end
end

