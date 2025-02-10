# ~/lib/ruby/estimate_tokens

def estimate_tokens(*args)
  string = args.join("\n")
  words = string.scan(/\w+/)
  words_per_token = 3.0/4.0
  (words.size * 1/words_per_token).to_i
end
