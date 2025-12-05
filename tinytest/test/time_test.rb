# frozen_string_literal: true

class TimeTest < Test
  def test_frozen_time
    stub_class(Time, now: Time.at(0))

    ok Time.now == Time.at(0)
  end
end
