# aliases_of.rb

# TODO: add ability to find aliases of class-level methods

def aliases_of(klass, a_symbol)

  klass.instance_methods.select do |a_method|
    klass.instance_method(a_method) == klass.instance_method(a_symbol)
  end.reject {| this_symbol| this_symbol == a_symbol }

end
