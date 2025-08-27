# jaccard_similarity.rb
#
# String similarity measurement using Jaccard index techniques
# Based on: https://en.wikipedia.org/wiki/Jaccard_index
#
# The Jaccard index measures similarity between finite sets and is defined as:
# J(A,B) = |A ∩ B| / |A ∪ B|
#
# This implementation provides multiple string comparison techniques:
# - Character-based similarity
# - Word-based similarity  
# - N-gram based similarity (bigrams, trigrams, etc.)

class JaccardSimilarity
  # Calculate basic Jaccard index for two sets
  # @param set1 [Set, Array] First set
  # @param set2 [Set, Array] Second set
  # @return [Float] Jaccard similarity coefficient (0.0 to 1.0)
  def self.jaccard_index(set1, set2)
    set1 = set1.to_set if set1.respond_to?(:to_set)
    set2 = set2.to_set if set2.respond_to?(:to_set)
    
    intersection = set1 & set2
    union = set1 | set2
    
    return 0.0 if union.empty?
    intersection.size.to_f / union.size
  end

  # Character-based Jaccard similarity
  # Compares strings based on unique characters
  # @param str1 [String] First string
  # @param str2 [String] Second string
  # @param case_sensitive [Boolean] Whether comparison is case sensitive
  # @return [Float] Similarity coefficient (0.0 to 1.0)
  def self.character_similarity(str1, str2, case_sensitive: false)
    return 1.0 if str1 == str2
    return 0.0 if str1.empty? || str2.empty?
    
    chars1 = case_sensitive ? str1.chars.to_set : str1.downcase.chars.to_set
    chars2 = case_sensitive ? str2.chars.to_set : str2.downcase.chars.to_set
    
    jaccard_index(chars1, chars2)
  end

  # Word-based Jaccard similarity
  # Compares strings based on unique words
  # @param str1 [String] First string
  # @param str2 [String] Second string
  # @param case_sensitive [Boolean] Whether comparison is case sensitive
  # @param word_separator [Regexp] Pattern to split words
  # @return [Float] Similarity coefficient (0.0 to 1.0)
  def self.word_similarity(str1, str2, case_sensitive: false, word_separator: /\s+/)
    return 1.0 if str1 == str2
    return 0.0 if str1.empty? || str2.empty?
    
    words1 = str1.split(word_separator).reject(&:empty?)
    words2 = str2.split(word_separator).reject(&:empty?)
    
    unless case_sensitive
      words1 = words1.map(&:downcase)
      words2 = words2.map(&:downcase)
    end
    
    jaccard_index(words1.to_set, words2.to_set)
  end

  # N-gram based Jaccard similarity
  # Compares strings based on character n-grams (substrings of length n)
  # @param str1 [String] First string
  # @param str2 [String] Second string
  # @param n [Integer] Length of n-grams (2 for bigrams, 3 for trigrams, etc.)
  # @param case_sensitive [Boolean] Whether comparison is case sensitive
  # @return [Float] Similarity coefficient (0.0 to 1.0)
  def self.ngram_similarity(str1, str2, n: 2, case_sensitive: false)
    return 1.0 if str1 == str2
    return 0.0 if str1.empty? || str2.empty?
    
    s1 = case_sensitive ? str1 : str1.downcase
    s2 = case_sensitive ? str2 : str2.downcase
    
    ngrams1 = generate_ngrams(s1, n)
    ngrams2 = generate_ngrams(s2, n)
    
    jaccard_index(ngrams1, ngrams2)
  end

  # Compare multiple strings and return similarity matrix
  # @param strings [Array<String>] Array of strings to compare
  # @param method [Symbol] Similarity method (:character, :word, :ngram)
  # @param **options Options to pass to the similarity method
  # @return [Array<Array<Float>>] Similarity matrix
  def self.similarity_matrix(strings, method: :character, **options)
    size = strings.length
    matrix = Array.new(size) { Array.new(size, 0.0) }
    
    (0...size).each do |i|
      (i...size).each do |j|
        similarity = if i == j
          1.0
        else
          case method
          when :character
            character_similarity(strings[i], strings[j], **options)
          when :word
            word_similarity(strings[i], strings[j], **options)
          when :ngram
            ngram_similarity(strings[i], strings[j], **options)
          else
            raise ArgumentError, "Unknown similarity method: #{method}"
          end
        end
        
        matrix[i][j] = similarity
        matrix[j][i] = similarity
      end
    end
    
    matrix
  end

  # Find the most similar string from a collection
  # @param target [String] String to find matches for
  # @param candidates [Array<String>] Collection of candidate strings
  # @param method [Symbol] Similarity method (:character, :word, :ngram)
  # @param threshold [Float] Minimum similarity threshold (0.0 to 1.0)
  # @param **options Options to pass to the similarity method
  # @return [Array<Hash>] Array of matches with similarity scores, sorted by similarity
  def self.find_similar(target, candidates, method: :character, threshold: 0.0, **options)
    results = candidates.map do |candidate|
      similarity = case method
      when :character
        character_similarity(target, candidate, **options)
      when :word
        word_similarity(target, candidate, **options)
      when :ngram
        ngram_similarity(target, candidate, **options)
      else
        raise ArgumentError, "Unknown similarity method: #{method}"
      end
      
      { string: candidate, similarity: similarity }
    end
    
    results.select { |r| r[:similarity] >= threshold }
           .sort_by { |r| -r[:similarity] }
  end

  private

  # Generate n-grams from a string
  # @param str [String] Input string
  # @param n [Integer] Length of n-grams
  # @return [Set] Set of n-grams
  def self.generate_ngrams(str, n)
    return Set.new if str.length < n
    
    ngrams = Set.new
    (0..str.length - n).each do |i|
      ngrams << str[i, n]
    end
    ngrams
  end
end