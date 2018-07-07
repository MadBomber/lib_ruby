# lib/ruby/my_delegator.rb
# See: https://goiabada.blog/delegating-methods-in-ruby-with-forwardable-ee2b86a6be32

module MyDelegator
  def self.included(klass)
    klass.extend(Forwardable)
    klass.extend(Macros)
  end

  module Macros
    def delegate(*methods, to:, as: nil)
      if as
        def_delegator to, methods.first, as
      else
        def_delegators to, *methods
      end
    end # def delegate(*methods, to:, as: nil)
  end # module Macros
end # module MyDelegator

__END__

# Example:

module Decorator
  class StudentDecorator
    include MyDelegator

    delegate :first_name, :last_name, :professors, :birthday, :course, to: :@student
    delegate :name, to: '@student.course', as: :course_name

    def initialize(student:)
      @student = student
    end

    def full_name
      "#{first_name} #{last_name}"
    end

    def professors_names
      professors.map(&:name).join(', ')
    end
  end
end
