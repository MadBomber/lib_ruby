## Constants for the Mission Planning GUI

## DEFAULT_NAME_REGEXP: lower case letters with single underscores between words
##   valid:   'a', 'a_b_c', 'any_string_that_looks_like_this'
##   invalid: '_underscore_on_either_end_', 'HAS_CAPITALS_nums_or_syms_123$%^'
DEFAULT_NAME_REGEXP = /\A([a-z0-9]+[_]?)*[a-z0-9]\Z/
DEFAULT_NAME_LENGTH = 32

## TEWA_NAME_REGEXP: lower case letters with single underscores between words
##   valid:   'a', 'a_b_c', 'any_string_that_looks_like_this'
##   invalid: '_underscore_on_either_end_', 'HAS_CAPITALS_nums_or_syms_123$%^'
TEWA_NAME_REGEXP = /\A([a-z]+[_]?)*[a-z]\Z/
TEWA_NAME_LENGTH = 32
