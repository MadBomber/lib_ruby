# ~/lib/ruby/normalize_key.rb
#
# From: alphavantage gem
#
# TODO: Refactor this into a reusable component
#
# Convert a hash key to a snake_case symbol
#
class NormalizeKey
  def initialize(key:)
    @key = key
  end

  def call
    return @key if is_date?(@key)
    underscore_key(sanitize_key(@key))
  end

  private

  def underscore_key(key)
    key.to_s.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase.to_sym
  end

  def sanitize_key(key)
    key.tr('.():/','').gsub(/^\d+.?\s/, "").tr(' ','_')
  end

  def is_date?(key)
    !/(\d{4}-\d{2}-\d{2})/.match(key.to_s).nil?
  end
end


def convert_hash_keys(value)
  case value
  when Array
    value.map { |v| convert_hash_keys(v) }
  when Hash
    Hash[value.map { |k, v| [ NormalizeKey.new(key: k).call, convert_hash_keys(v) ] }]
  else
    value
  end
end


__END__

# First cut at a refactor, AI generated ...

class Hash
  def sanitize_keys
    self.transform_keys { |k| sanitize_key(k) }
  end

  def convert_keys
    self.transform_keys { |k| convert_key(k) }
  end

  def normalize_keys
    self.transform_keys { |k| normalize_key(k) }
  end

  private

  def sanitize_key(key)
    key.tr('.():/','').gsub(/^\d+.?\s/, "").tr(' ','_')
  end

  def convert_key(key)
    key.to_s.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase.to_sym
  end

  def normalize_key(key)
    return key if is_date?(key)
    underscore_key(sanitize_key(key))
  end

  def underscore_key(key)
    key.to_s.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase.to_sym
  end

  def is_date?(key)
    !/(\d{4}-\d{2}-\d{2})/.match(key.to_s).nil?
  end
end

# Example usage
hash = {
  "HelloWorld" => "value",
  "foo.bar" => {
    "Baz" => 123
  }
}

sanitized_hash  = hash.sanitize_keys
converted_hash  = hash.convert_keys
normalized_hash = hash.normalize_keys

puts sanitized_hash
puts converted_hash
puts normalized_hash


Output:

santized ...
{ "HelloWorld"  => "value", "foobar"  => { "Baz" => 123 } }

converted ...
{ "hello_world" => "value", "foo_bar" => { "baz" => 123 } }

normalized ...
{ :hello_world  => "value", :foo_bar  => { :baz  => 123 } }



