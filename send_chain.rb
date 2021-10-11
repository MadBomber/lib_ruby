# lib/ruby/send_chain.rb

# send a sequence of dynmaic non-parameterized method names to an object
# array_of_method_names is an Array of String or Symbol
#
# Returns the result of the sequence
#
def send_chain(array_of_method_names)
  array_of_method_names&.inject(self) {|obj, msg| obj&.send(msg) }
end
