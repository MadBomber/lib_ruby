require 'digest'

# Probabilistic distinct-element counter using HyperLogLog.
#
# Trades exactness for constant memory: regardless of how many elements
# you've seen, state is always 2^precision bytes. Default precision 14
# uses 16 384 buckets (~12 KB) and achieves ~0.81% standard error.
#
# Complexity:
#   add   — O(1)
#   count — O(m) where m = 2^precision
#   merge — O(m)
class HyperLogLog
  attr_reader :precision

  def initialize(precision: 14)
    raise ArgumentError, "precision must be between 4 and 16" unless (4..16).include?(precision)
    @precision = precision
    @m         = 1 << precision
    @buckets   = Array.new(@m, 0)
    @alpha     = alpha_for(@m)
  end

  def add(value)
    h      = hash64(value)
    bucket = h >> (64 - @precision)
    bits   = h & ((1 << (64 - @precision)) - 1)
    rank   = leading_zeros(bits, 64 - @precision) + 1
    @buckets[bucket] = rank if rank > @buckets[bucket]
    self
  end

  alias << add

  def count
    raw = raw_estimate
    if raw <= 2.5 * @m
      zeros = @buckets.count(0)
      zeros > 0 ? linear_count(zeros) : raw
    elsif raw <= (2**32) / 30.0
      raw
    else
      -(2**32) * Math.log(1.0 - raw / (2**32))
    end
  end

  # Returns a new HyperLogLog combining self and other (non-destructive).
  def merge(other)
    assert_compatible!(other)
    result = self.class.new(precision: @precision)
    other_buckets = other.instance_variable_get(:@buckets)
    result.instance_variable_set(
      :@buckets,
      @m.times.map { |i| [@buckets[i], other_buckets[i]].max }
    )
    result
  end

  # Merges other into self in place.
  def merge!(other)
    assert_compatible!(other)
    other_buckets = other.instance_variable_get(:@buckets)
    @m.times { |i| @buckets[i] = [@buckets[i], other_buckets[i]].max }
    self
  end

  def size = @m

  private

  def hash64(value)
    Digest::SHA256.digest(value.to_s).unpack1('Q>')
  end

  def leading_zeros(bits, bit_width)
    return bit_width if bits == 0
    n    = 0
    mask = 1 << (bit_width - 1)
    while mask > 0 && (bits & mask) == 0
      n    += 1
      mask >>= 1
    end
    n
  end

  def raw_estimate
    sum = @buckets.sum { |b| 2.0**(-b) }
    @alpha * @m * @m / sum
  end

  def linear_count(zeros)
    @m * Math.log(@m.to_f / zeros)
  end

  def alpha_for(m)
    case m
    when 16 then 0.673
    when 32 then 0.697
    when 64 then 0.709
    else         0.7213 / (1.0 + 1.079 / m)
    end
  end

  def assert_compatible!(other)
    raise ArgumentError, "precision mismatch (#{@precision} vs #{other.precision})" \
      unless other.precision == @precision
  end
end
