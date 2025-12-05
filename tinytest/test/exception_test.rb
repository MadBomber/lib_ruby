# frozen_string_literal: true

class ExceptionTest < Test
  def test_raised
    raised = false

    begin
      raise ArgumentError, "invalid argument"
    rescue ArgumentError
      raised = true
    end

    ok raised, "did not raise ArgumentError"
  end

  def test_not_raised
    raised = false
    err = nil

    begin
      10 / 2
    rescue => e
      err = e
      raised = true
    end

    ok !raised, "raised #{err}"
  end
end
