# frozen_string_literal: true

class NilTest < Test
  def test_nil
    val = nil
    ok val == nil, "#{val} not nil"
  end

  def test_not_nil
    val = "value"
    ok val != nil, "val is nil"
  end
end
