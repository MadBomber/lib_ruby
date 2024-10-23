#!/usr/bin/env ruby
# lib/ruby/extract_paragraph_number.rb
#
# TODO: add the 'engtagger' library to see if the
#       next word following "I" is a verb.  If so, then
#       "I" is not a roman numberial, but a pronoun.
#       which is still not good enough since some
#       parts or section names could start with a
#       verb.

# text (String) a single line of text
# returns (String) or nil
def extract_paragraph_number(text)
  # Updated regex to match valid paragraph numbers (numeric or Roman numerals)
  regex = /^\s*(\d+(\.\d+)*|[ivxlcdm]{1,3}|[IVXLCDM]{1,3})([\.\)])?\s/

  # Match the text against the regex
  match = text.match(regex)

  # Ensure "I" is not matched unless it follows the correct formatting
  if match && match[1] == "I"
    return match[1] if text.match?(/^\s*I[\.\)]/)
    return nil
  end

  # Return paragraph number if a match is found
  return match[1] if match

  # Return nil if no valid match is found
  nil
end

__END__

# Example usage
puts extract_paragraph_number("1. This is a paragraph.") # Output: "1"
puts extract_paragraph_number("1.2.3. This is a paragraph.") # Output: "1.2.3"
puts extract_paragraph_number("1.2.3 This is a paragraph.") # Output: "1.2.3"
puts extract_paragraph_number(" 1) This is a sub-paragraph.") # Output: "1"
puts extract_paragraph_number("I. This is an uppercase paragraph.") # Output: "I"
puts extract_paragraph_number("I Eat at Joes!") # Output: nil
puts extract_paragraph_number("I am hungry") # Output: nil
puts extract_paragraph_number("i) This is a lowercase Roman numeral paragraph.") # Output: "i"
puts extract_paragraph_number("This is a paragraph without a number.") # Output: nil
puts extract_paragraph_number("xyzzy is magic") # Output: nil
puts extract_paragraph_number("Abc. This should not be a number.") # Output: nil
puts extract_paragraph_number("1A. This should not be a number.") # Output: nil
