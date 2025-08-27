# ~/lib/ruby/find_matching_entries.rb
#

require 'set'

def find_matching_entries(store, data, limit = 10)
  return [] if data.empty?

  matches   = Hash.new { |hash, key| hash[key] = [] }
  data      = data.map(&:downcase)
  max_count = data.size

  store.each_with_index do |entry, index|
    next if entry.empty?

    match_count = (entry.map(&:downcase) & data).size

    if match_count > 0
      matches[match_count] << { entry: entry, index: index }
      break if match_count == max_count && matches[match_count].size >= limit
    end
  end

  # If there are matches, find the maximum match count
  if matches.any?
    max_matches = matches.keys.max
    top_matches = matches[max_matches]

    # Limit the number of results to the specified limit
    top_matches.first(limit)
  else
    # Return an empty array if no matches were found at all
    []
  end
end

# Truly optimized version that avoids repeated downcasing
def find_matching_entries_fast(store, data, limit = 10)
  return [] if data.empty?

  data_lower = data.map(&:downcase)
  data_set = data_lower.to_set
  max_count = data.size

  # Single pass with priority queue concept
  top_k = []
  min_score = 0

  store.each_with_index do |entry, index|
    next if entry.empty?

    # Avoid downcasing if we can't beat current minimum
    if top_k.size >= limit && entry.size < min_score
      next
    end

    # Count matches efficiently
    match_count = 0
    entry.each do |item|
      item_lower = item.downcase
      match_count += 1 if data_set.include?(item_lower)
      # Early exit if we found all possible matches
      break if match_count == max_count
    end

    next if match_count == 0
    next if top_k.size >= limit && match_count <= min_score

    # Insert into top_k maintaining order
    inserted = false
    top_k.each_with_index do |existing, i|
      if match_count > existing[0]
        top_k.insert(i, [match_count, { entry: entry, index: index }])
        inserted = true
        break
      end
    end

    if !inserted && top_k.size < limit
      top_k << [match_count, { entry: entry, index: index }]
    end

    # Trim to limit and update min_score
    if top_k.size > limit
      top_k.pop
    end
    min_score = top_k.last[0] if top_k.size >= limit

    # Early exit if we have enough perfect matches
    if match_count == max_count
      perfect_count = top_k.count { |item| item[0] == max_count }
      break if perfect_count >= limit
    end
  end

  top_k.map { |item| item[1] }
end

__END__

# Example usage:
store = [["apple", "banana", "cherry"], ["banana", "kiwi"], ["apple", "banana", "kiwi"], ["kiwi", "banana"]]
data = ["banana", "kiwi"]

result = find_matching_entries(store, data, 2)
puts result.inspect


##################################

⏺ For finding documents with matching keywords in a PostgreSQL database (assuming you're using PostgreSQL since you mentioned
  array columns), here's the optimal approach:

  SQL Query Options

  1. Using Array Overlap Operator (&&) - Simplest

  SELECT *, cardinality(keywords & ARRAY['banana', 'kiwi']::text[]) as match_count
  FROM documents
  WHERE keywords && ARRAY['banana', 'kiwi']::text[]
  ORDER BY match_count DESC
  LIMIT 10;

  2. Using Array Contains (@>) for Exact Matches

  -- For documents containing ALL keywords
  SELECT *
  FROM documents
  WHERE keywords @> ARRAY['banana', 'kiwi']::text[]
  LIMIT 10;

  3. Scoring by Match Count (Most Similar to Ruby Version)

  WITH scored_docs AS (
    SELECT *,
      cardinality(keywords & ARRAY['banana', 'kiwi']::text[]) as match_count,
      cardinality(keywords) as total_keywords
    FROM documents
    WHERE keywords && ARRAY['banana', 'kiwi']::text[]
  )
  SELECT *
  FROM scored_docs
  ORDER BY match_count DESC, total_keywords ASC
  LIMIT 10;

  Indexing Strategy

  YES, absolutely index the keywords column! Use a GIN (Generalized Inverted Index) index:

  CREATE INDEX idx_documents_keywords ON documents USING GIN (keywords);

  GIN indexes are specifically designed for this use case and will dramatically improve performance for:
  - && (overlap)
  - @> (contains)
  - <@ (contained by)
  - = (equality)

  Performance Comparison

  Without index:
  - Full table scan required
  - O(n) where n = number of rows
  - Slow on large tables

  With GIN index:
  - Direct lookup using inverted index
  - O(log n) + O(m) where m = matching documents
  - Orders of magnitude faster on large tables

  Alternative: Full-Text Search

  If keywords are actually text/tags, consider using PostgreSQL's full-text search:

  -- Add a tsvector column
  ALTER TABLE documents ADD COLUMN keywords_tsv tsvector;
  UPDATE documents SET keywords_tsv = to_tsvector('simple', array_to_string(keywords, ' '));
  CREATE INDEX idx_documents_keywords_tsv ON documents USING GIN (keywords_tsv);

  -- Query
  SELECT *, ts_rank(keywords_tsv, query) as rank
  FROM documents, to_tsquery('simple', 'banana | kiwi') query
  WHERE keywords_tsv @@ query
  ORDER BY rank DESC
  LIMIT 10;

  Benchmark Example

  -- Create test data
  CREATE TABLE documents (
    id serial PRIMARY KEY,
    keywords text[]
  );

  -- Insert sample data
  INSERT INTO documents (keywords)
  SELECT ARRAY(SELECT 'word' || generate_series(1, 10 + random()*20)::text)
  FROM generate_series(1, 100000);

  -- Test without index
  EXPLAIN ANALYZE
  SELECT *, cardinality(keywords & ARRAY['word5', 'word10']::text[]) as matches
  FROM documents
  WHERE keywords && ARRAY['word5', 'word10']::text[]
  ORDER BY matches DESC
  LIMIT 10;

  -- Add GIN index
  CREATE INDEX idx_keywords ON documents USING GIN (keywords);

  -- Test with index (will be MUCH faster)
  EXPLAIN ANALYZE
  SELECT *, cardinality(keywords & ARRAY['word5', 'word10']::text[]) as matches
  FROM documents
  WHERE keywords && ARRAY['word5', 'word10']::text[]
  ORDER BY matches DESC
  LIMIT 10;

  The GIN index typically provides 10-100x speedup for array overlap queries on large tables.
