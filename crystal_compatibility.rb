# ~/lib/ruby/crystal_compatibility.rb

=begin

  Monkey oatch Ruby classes to match method names used by the Crystal
  compiled language. Intended use is the development of methods/classes
  which are executable by both Ruby and Crystal.

  As a convention files which contain exclusively Crystal/Ruby compatible
  code should have the extension *.crb

=end


# TODO: find other classes in which Ruby/Crystal differ

class Array
  alias_method :includes?, :include?
end

class Pathname
  alias_method :exists?, :exist?
end

class String
  alias_method :starts_with?, :start_with?
  alias_method :ends_with?,   :end_with?
  alias_method :includes?,    :include?
end
