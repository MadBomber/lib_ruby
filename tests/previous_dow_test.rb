# ~/lib/ruby/tests/previous_dow_test.rb

require 'minitest/autorun'
require_relative '../previous_dow'

class String
  def to_date
    Date.parse self 
  end
end


class PreviousDowTest < Minitest::Test
  def test_sunday
    result = previous_dow(:sunday, "2023-07-15".to_date)
    assert_equal result.to_s, "2023-07-09"
  end

  def test_sunday_not_today
    result = previous_dow(:sunday, "2023-07-09".to_date)
    assert_equal result.to_s, "2023-07-02"
  end

  def test_sunday_is_yesterday
    result = previous_dow(:sunday, "2023-07-10".to_date)
    assert_equal result.to_s, "2023-07-09"
  end

  def test_error_dow
    assert_raises do
      result = previous_dow(:xyzzy)
    end
  end

  def test_error_date
    assert_raises do
      result = previous_dow(:sunday, "2023-07-04")
    end
  end


end

__END__

2023-06-15 thursday
2023-06-16 friday
2023-06-17 saturday
2023-06-18 sunday
2023-06-19 monday
2023-06-20 tuesday
2023-06-21 wednesday
2023-06-22 thursday
2023-06-23 friday
2023-06-24 saturday
2023-06-25 sunday
2023-06-26 monday
2023-06-27 tuesday
2023-06-28 wednesday
2023-06-29 thursday
2023-06-30 friday
2023-07-01 saturday
2023-07-02 sunday
2023-07-03 monday
2023-07-04 tuesday
2023-07-05 wednesday
2023-07-06 thursday
2023-07-07 friday
2023-07-08 saturday
2023-07-09 sunday
2023-07-10 monday
2023-07-11 tuesday
2023-07-12 wednesday
2023-07-13 thursday
2023-07-14 friday
2023-07-15 saturday

