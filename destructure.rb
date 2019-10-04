# ~/lib/ruby/destructure.rb
# See: https://medium.com/@baweaver/destructuring-in-ruby-9e9bd2be0360

def destructure(method_name)
  meta_klass  = class << self; self end
  method_proc = method(method_name)

  unless method_proc.parameters.all? { |t, _| t == :key }
    raise "Only works with keyword arguments"
  end

  arguments = method_proc.parameters.map(&:last)

  destructure_proc = -> object {
    values = if object.is_a?(Hash)
      object
    else
      arguments.map { |a| [a, object.public_send(a)] }.to_h
    end

    method_proc.call(values)
  }

  meta_klass.send(:define_method, method_name, destructure_proc)

  method_name
end
