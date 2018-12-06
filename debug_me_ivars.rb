# lib/ruby/debug_me_ivars.rb

class Object
  def debug_me_ivars
    my_hash = Hash.new
    self.instance_variables.each do |attribute|
      my_hash.merge!({ attribute => self.instance_variable_get(attribute) })
    end
    return my_hash
  end
end

__END__

instance_object = SomeSubClassOfObject.new

ap instance_object.debug_me_ivars
