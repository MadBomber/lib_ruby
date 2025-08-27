##############################################
###
##  File: refinements_string.rb
##  Desc: some common refinements on the String class
#

require 'active_support/all'
require_relative 'jaccard_similarity'

module Refinements

  refine ::String do

    # return only the digits 0123456789 found in a string as a string.
    # Useful to squeezing out junk in phone numbers and SSN data objects
    def to_digits
      self.gsub(/\D/,'')
    end

    # treats the string as a binary buffer.  Returns a new
    # string (suitable for printing) of the hexidecimal vaules of the buffer
    def as_hex
      self.bytes.map { |byte| sprintf('%02x', byte) }.join(' ')
    end

    # Is the String a numeric?
    def numeric?
      self.match(/\A[+-]?\d+(\.\d+)?\z/) != nil
    end

    # Calculate similarity between this string and another using Jaccard index
    # @param other_string [String] String to compare with
    # @param method [Symbol] Similarity method (:character, :word, :ngram)
    # @param **options Additional options passed to similarity calculation
    # @return [Float] Similarity coefficient (0.0 to 1.0)
    def how_similar(other_string, method: :character, **options)
      case method
      when :character
        JaccardSimilarity.character_similarity(self, other_string, **options)
      when :word
        JaccardSimilarity.word_similarity(self, other_string, **options)
      when :ngram
        JaccardSimilarity.ngram_similarity(self, other_string, **options)
      else
        raise ArgumentError, "Unknown similarity method: #{method}. Use :character, :word, or :ngram"
      end
    end

    # Check if this string is similar to another string above a threshold
    # @param other_string [String] String to compare with
    # @param threshold [Float] Minimum similarity threshold (default: 0.5)
    # @param method [Symbol] Similarity method (:character, :word, :ngram)
    # @param **options Additional options passed to similarity calculation
    # @return [Boolean] True if similarity is >= threshold
    def similar_to?(other_string, threshold: 0.5, method: :character, **options)
      how_similar(other_string, method: method, **options) >= threshold
    end
  end # refine String do

end # module Refinements
