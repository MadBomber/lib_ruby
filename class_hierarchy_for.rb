# lib/ruby/class_hierarchy_for.rb
#
# An interesting way to introspec a class
#

def class_hierarchy_for a_class

  class_array   = []
  tree          = {}

  ObjectSpace.each_object(Class) do |klass|
    next unless klass.ancestors.include? a_class
    next if class_array.include? klass

    if Exception == a_class
      next if klass.superclass == SystemCallError # ignore Errno
    end

    class_array << klass

    klass
      .ancestors
      .delete_if {|e| [Object, Kernel].include? e }
      .reverse
      .inject(tree) {|memo,klass| memo[klass] ||= {}}
  end # ObjectSpace.each_object(Class) do |klass|

  return tree
end
