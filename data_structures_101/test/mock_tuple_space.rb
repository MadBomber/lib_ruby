# Minimal in-process tuple space for unit testing Linda-style classes.
# nil in a template acts as a wildcard. Raises rather than blocks on
# missing tuples so tests fail fast instead of hanging.
class MockTupleSpace
  def initialize
    @tuples = []
  end

  def write(tuple)
    @tuples << tuple.dup
    tuple
  end

  def take(template)
    idx = @tuples.index { |t| matches?(t, template) }
    raise "No tuple matching #{template.inspect} (have: #{@tuples.inspect})" if idx.nil?
    @tuples.delete_at(idx)
  end

  def read(template)
    @tuples.find { |t| matches?(t, template) }
  end

  def read_all(template)
    @tuples.select { |t| matches?(t, template) }
  end

  def tuples = @tuples.dup

  private

  def matches?(tuple, template)
    return false unless tuple.size == template.size
    template.each_with_index.all? { |pat, i| pat.nil? || pat == tuple[i] }
  end
end
