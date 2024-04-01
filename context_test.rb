# ~/lib/ruby/context_test.rb
#
# See: https://gist.github.com/srbaker/a532f43df9de90f5fd9d600039b4eaea
#
# I have edited the comment slightly ...

##
# A demonstration of how you might implement a context helper in a
# declarative style for Minitest, when you use the declarative style
# from ActiveSupport.
#
# It's a fun hack, of the sort I like in Ruby.  But you probably
# shouldn't use it.
#
# No, you definitely should not use this.  
#
# <snip>
#
# If you think this kind of thing is clever, or you like the stuff I
# create, you should definitely email me so we can work together.  I'd
# like to help you make your test suites more resilient, and your code
# better.
#
# Fan mail can be sent to: steven@stevenrbaker.com
#
# I would be happy to discuss this, why it's wonky, and stuff.  I do
# love Ruby.
#
#


# These next few lines are to make this file a self-contained
# executable demonstration.

=begin

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'minitest'
  gem 'activesupport'
end

=end

################################################
###
##  Put this into a helper file.
#

require "minitest/autorun"
require "active_support"

module Context
  def context name, &block
    context_name = "Context#{name.gsub(/\s+/, '_').camelize}".to_sym
    context_class = Object.const_set context_name, Class.new(self)

    context_class.instance_methods.select { |method| method.to_s.start_with? "test_" }.each do |method|
      context_class.undef_method method
    end

    context_class.class_eval &block
  end
end

class ContextTest < ActiveSupport::TestCase
  extend Context
end

#
##  End of helper file
###
################################################


__END__

# Usage ...

class FooTest < ContextTest
  def setup
    @foo = "foo"
  end

  test "foo is foo" do
    assert_equal "foo", @foo
  end

  test "bar is undefined" do
    assert_nil @bar
  end

  context "with bar and baz" do
    def setup
      super # FIXME: this is fucked, it should be done in #context
      @bar = "bar"
      @baz = "baz"
    end

    test "bar is bar" do
      assert_equal "bar", @bar
    end

    test "baz is baz" do
      assert_equal "bar", @bar
    end

    test "foo is still foo" do
      assert_equal "foo", @foo
    end
  end

  context "with qux but not bar and baz" do
    def setup
      super # FIXME: still fucked
      @qux = "qux"
    end
    
    test "bar is undefined" do
      assert_nil @bar
    end

    test "baz is undefined" do
      assert_nil @bar
    end

    test "foo is still foo" do
      assert_equal "foo", @foo
    end

    test "qux is qux" do
      assert_equal "qux", @qux
    end
  end

  context "with a nested context" do
    def setup
      super # FIXME: still fucked
      @quux = "quux"
    end

    test "quux is quux" do
      assert_equal "quux", @quux
    end

    context "the nested context" do
      test "quux and foo exist, but not bar or baz or qux" do
        assert_equal "quux", @quux
        assert_equal "foo", @foo

        assert_nil @bar
        assert_nil @baz
        assert_nil @qux
      end
    end
  end
end

