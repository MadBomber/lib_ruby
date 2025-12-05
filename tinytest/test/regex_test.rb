# frozen_string_literal: true

class RegexTest < Test
  def test_match
    got = "user@example.com"
    want = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    ok got =~ want, "#{got} not email format"
  end

  def test_no_match
    got = "text"
    ok got !~ /[<>]/, "#{got} contains HTML brackets"
  end
end
