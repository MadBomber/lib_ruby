# lib/rubh/process_later.rb
# from https://www.saturnflyer.com/blog/turning-a-specific-solution-into-a-general-tool

=begin
# User it like this ...

class SomeProcess
  include ProcessLater

  def initialize(some_id)
    @initializer_arguments = [some_id]
    @object = User.find(some_id)
  end
  attr_reader :initializer_arguments

  def call
    # perform some long-running action
  end
end

=end

module ProcessLater
  def later(which_method)
    later_class.enqueue(initializer_arguments, 'trigger_method' => which_method)
  end

  private

  def later_class
    self.class.const_get(:Later)
  end

  class Later < Que::Job
    # create the class lever accessor get the related class
    class << self
      attr_accessor :class_to_run
    end

    # create the instance method to access it
    def class_to_run
      self.class.class_to_run
    end

    def run(*args)
      options = args.pop # get the hash passed to enqueue
      self.class_to_run.new(args).send(options['trigger_method'])
    end
  end

  def self.included(klass)
    # create the unnamed class which inherits what we need
    later_class = Class.new(::ProcessLater::Later)

    # name the class we just created
    klass.const_set(:Later, later_class)

    # assign the class_to_run variable to hold a reference
    later_class.class_to_run = klass
  end
end
