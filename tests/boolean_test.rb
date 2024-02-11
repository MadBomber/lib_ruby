# ~/lib/ruby/tests/boolean_test.rb

require 'minitest/autorun'
require 'boolean' # Assume the source code is saved in boolean_extensions.rb

class BooleanTest < Minitest::Test
  def test_true_to_i
    assert_equal 1, true.to_i
  end

  def test_false_to_i
    assert_equal 0, false.to_i
  end

  def test_true_to_s
    assert_equal 'true', true.to_s
  end

  def test_false_to_s
    assert_equal 'false', false.to_s
  end

  def test_true_and_true
    assert_equal true, true.and(true)
  end

  def test_true_and_false
    assert_equal false, true.and(false)
  end

  def test_false_or_true
    assert_equal true, false.or(true)
  end

  def test_false_or_false
    assert_equal false, false.or(false)
  end

  def test_not_true
    assert_equal false, true.not
  end

  def test_not_false
    assert_equal true, false.not
  end

  def test_true_xor_true
    assert_equal false, true.xor(true)
  end

  def test_true_xor_false
    assert_equal true, true.xor(false)
  end

  def test_boolean_class_methods
    assert_equal true, Boolean.true
    assert_equal false, Boolean.false
  end

  def test_kernel_to_boolean_true
    assert_equal true, true.to_b
  end

  def test_kernel_to_boolean_false
    assert_equal false, false.to_b
  end

  def test_kernel_to_boolean_error
    assert_raises(TypeError) { 123.to_b }
  end

  def test_is_a_override
    assert true.is_a?(Boolean)
    assert !123.is_a?(Boolean)
  end
end