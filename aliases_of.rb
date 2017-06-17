# aliases_of.rb
#
# from the library of the MadBomber
#

def aliases_of(klass, a_symbol)

  klass.instance_methods.select do |a_method|
    klass.instance_method(a_method) == klass.instance_method(a_symbol)
  end.reject {| this_symbol| this_symbol == a_symbol }

end
