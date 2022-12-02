# ~/lib/ruby/options.rb


# Like a mini or light version of Hashie
# provides method-level access to hash keys
class Options
  DEFAULT = nil     # any key added gets this default value

  def initialize(a_hash)
    from_h(a_hash)
  end


  # Does this options instance have a specific key?
  def has?(key)
    respond_to? key
  end


  # add some keys to this options instance
  # uses instance_eval to define getter and setter for
  # each key just like the attr_accessor does.
  def add(*array_of_string_or_sym)
    Array(array_of_string_or_sym).reject{|key| has?(key.to_s)}.each do |key|
      instance_eval <<~EOM
        def #{key}
          @#{key}
        end

        def #{key}=(a_value)
          @#{key} = a_value
        end
      EOM
      send "#{key}=", DEFAULT # NOTE: instance varible not created until set
    end
  end


  # From an existing hash, add its keys and values to
  # this options instance.
  def from_h(a_hash)
    a_hash.each_pair do |k, v|
      add k
      send("#{k}=", v)
    end
  end


  # convert this options instance into a hash
  def to_h
    a_hash = Hash.new
    keys = instance_variables.map{|var| var.to_s.gsub('@','')}
    keys.each do |key|
      a_hash[key] = send key
    end
    return a_hash
  end
end # class Options
