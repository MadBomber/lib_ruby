#!/usr/bin/env ruby

require 'minitest/autorun'
require_relative '../uuidv7'

class UUIDv7Test < Minitest::Test

  def test_returns_byte_array
    uuid_bytes = uuidv7
    assert_kind_of Array, uuid_bytes
    assert_equal 16, uuid_bytes.length
    uuid_bytes.each { |byte| assert_kind_of Integer, byte }
  end

  def test_bytes_are_valid_range
    uuid_bytes = uuidv7
    uuid_bytes.each do |byte|
      assert byte >= 0 && byte <= 255, "Byte #{byte} not in valid range 0-255"
    end
  end

  def test_version_bits_set_correctly
    uuid_bytes = uuidv7
    # Version should be 7 (0x70) - check the version bits in byte 6
    version_byte = uuid_bytes[6]
    version_nibble = (version_byte & 0xF0) >> 4
    assert_equal 7, version_nibble, "Version should be 7"
  end

  def test_variant_bits_set_correctly
    uuid_bytes = uuidv7
    # Variant bits should be 10 in the most significant bits of byte 8
    variant_byte = uuid_bytes[8]
    variant_bits = (variant_byte & 0xC0) >> 6
    assert_equal 2, variant_bits, "Variant should be 10 (binary) = 2 (decimal)"
  end

  def test_timestamp_encoding
    # The first 6 bytes should contain the timestamp
    before_time = (Time.now.to_f * 1000).to_i
    uuid_bytes = uuidv7
    after_time = (Time.now.to_f * 1000).to_i

    # Extract timestamp from first 6 bytes
    extracted_timestamp = 0
    (0..5).each do |i|
      extracted_timestamp = (extracted_timestamp << 8) | uuid_bytes[i]
    end

    assert extracted_timestamp >= before_time, "Timestamp should be >= test start time"
    assert extracted_timestamp <= after_time, "Timestamp should be <= test end time"
  end

  def test_generates_different_uuids
    uuid1 = uuidv7
    uuid2 = uuidv7
    refute_equal uuid1, uuid2, "Should generate different UUIDs"
  end

  def test_uuid_hex_format
    uuid_bytes = uuidv7
    hex_string = uuid_bytes.pack('C*').unpack1('H*')
    
    # Should be 32 hex characters
    assert_equal 32, hex_string.length
    assert_match(/^[0-9a-f]{32}$/i, hex_string)
  end

  def test_formatted_uuid_string
    uuid_bytes = uuidv7
    hex_string = uuid_bytes.pack('C*').unpack1('H*')
    
    # Format as standard UUID: 8-4-4-4-12
    formatted = [
      hex_string[0..7],
      hex_string[8..11], 
      hex_string[12..15],
      hex_string[16..19],
      hex_string[20..31]
    ].join('-')
    
    # Should match UUID format
    assert_match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i, formatted)
  end

  def test_timestamp_increments_over_time
    uuid1_bytes = uuidv7
    sleep(0.001) # Small delay
    uuid2_bytes = uuidv7
    
    # Extract timestamps
    ts1 = 0
    ts2 = 0
    (0..5).each do |i|
      ts1 = (ts1 << 8) | uuid1_bytes[i]
      ts2 = (ts2 << 8) | uuid2_bytes[i]
    end
    
    assert ts2 >= ts1, "Later UUID should have equal or greater timestamp"
  end

  def test_multiple_uuids_have_consistent_version_and_variant
    5.times do
      uuid_bytes = uuidv7
      
      # Check version (byte 6, high nibble should be 7)
      version_nibble = (uuid_bytes[6] & 0xF0) >> 4
      assert_equal 7, version_nibble
      
      # Check variant (byte 8, high 2 bits should be 10)
      variant_bits = (uuid_bytes[8] & 0xC0) >> 6
      assert_equal 2, variant_bits
    end
  end

end