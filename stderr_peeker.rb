# stderr_peeker.rb
# outputs the location of where the STDERR is used
# See: https://samsaffron.com/archive/2018/08/07/finding-where-stdout-stderr-debug-messages-are-coming-from

class << STDERR
  alias_method :orig_write, :write
  def write(x)
    orig_write(caller[0..3].join("\n"))
    orig_write(x)
  end
end
