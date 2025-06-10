require 'minitest/autorun'
require_relative '../hookable'

class HookableTest < Minitest::Test
  def setup
    @test_class = Class.new do
      include Hookable

      def test_method(param1, param2)
        "result: #{param1}, #{param2}"
      end

      def simple_method
        "simple result"
      end

      private

      def private_method(msg)
        msg.upcase
      end
    end
    @obj = @test_class.new
  end

  def teardown
    # Clear all hooks after each test
    @test_class.instance_variable_set(:@hooks, Hash.new { |h, k| h[k] = { before: [], after: [], around: [] } })
  end

  def test_before_hook_execution
    executed = false
    @test_class.before :test_method do |param1, param2|
      executed = true
    end

    @obj.test_method("a", "b")
    assert executed, "Before hook should have been executed"
  end

  def test_before_hook_parameter_modification
    @test_class.before :test_method do |param1, param2|
      [param1.upcase, param2.upcase]
    end

    result = @obj.test_method("hello", "world")
    assert_equal "result: HELLO, WORLD", result
  end

  def test_multiple_before_hooks
    execution_order = []
    
    @test_class.before :test_method do |param1, param2|
      execution_order << :first
      [param1 * 2, param2]
    end

    @test_class.before :test_method do |param1, param2|
      execution_order << :second
      [param1, param2 + "!"]
    end

    result = @obj.test_method("hi", "bye")
    assert_equal [:first, :second], execution_order
    assert_equal "result: hihi, bye!", result
  end

  def test_after_hook_execution
    after_result = nil
    @test_class.after :test_method do |result|
      after_result = result
    end

    original_result = @obj.test_method("a", "b")
    assert_equal original_result, after_result
  end

  def test_multiple_after_hooks
    execution_order = []
    
    @test_class.after :test_method do |result|
      execution_order << :first
    end

    @test_class.after :test_method do |result|
      execution_order << :second
    end

    @obj.test_method("a", "b")
    assert_equal [:first, :second], execution_order
  end

  def test_around_hook_execution
    around_executed = false
    @test_class.around :test_method do |*args, &block|
      around_executed = true
      block.call
    end

    @obj.test_method("a", "b")
    assert around_executed, "Around hook should have been executed"
  end

  def test_multiple_around_hooks_nesting
    execution_order = []
    
    @test_class.around :test_method do |*args, &block|
      execution_order << :first_before
      result = block.call
      execution_order << :first_after
      result
    end

    @test_class.around :test_method do |*args, &block|
      execution_order << :second_before
      result = block.call
      execution_order << :second_after
      result
    end

    @obj.test_method("a", "b")
    assert_equal [:first_before, :second_before, :second_after, :first_after], execution_order
  end

  def test_combined_hooks_execution_order
    execution_order = []
    
    @test_class.before :test_method do |param1, param2|
      execution_order << :before
      [param1, param2]
    end

    @test_class.around :test_method do |*args, &block|
      execution_order << :around_before
      result = block.call
      execution_order << :around_after
      result
    end

    @test_class.after :test_method do |result|
      execution_order << :after
    end

    @obj.test_method("a", "b")
    assert_equal [:before, :around_before, :around_after, :after], execution_order
  end

  def test_private_method_hooks
    executed = false
    @test_class.before :private_method do |msg|
      executed = true
      msg
    end

    result = @obj.send(:private_method, "hello")
    assert executed, "Hook on private method should execute"
    assert_equal "HELLO", result
  end

  def test_hooks_for_method
    @test_class.before :test_method do |param1, param2|
      [param1, param2]
    end

    @test_class.after :test_method do |result|
      result
    end

    hooks = @test_class.hooks_for(:test_method)
    assert_equal 1, hooks[:before].length
    assert_equal 1, hooks[:after].length
    assert_equal 0, hooks[:around].length
  end

  def test_clear_hooks_specific_type
    @test_class.before :test_method do |param1, param2|
      [param1, param2]
    end

    @test_class.after :test_method do |result|
      result
    end

    @test_class.clear_hooks(:test_method, :before)
    hooks = @test_class.hooks_for(:test_method)
    assert_equal 0, hooks[:before].length
    assert_equal 1, hooks[:after].length
  end

  def test_clear_all_hooks
    @test_class.before :test_method do |param1, param2|
      [param1, param2]
    end

    @test_class.after :test_method do |result|
      result
    end

    @test_class.clear_hooks(:test_method)
    hooks = @test_class.hooks_for(:test_method)
    assert_equal 0, hooks[:before].length
    assert_equal 0, hooks[:after].length
    assert_equal 0, hooks[:around].length
  end

  def test_hook_without_block_raises_error
    assert_raises(ArgumentError) do
      @test_class.before(:test_method)
    end
  end

  def test_hook_on_nonexistent_method_raises_error
    assert_raises(ArgumentError) do
      @test_class.before(:nonexistent_method) { }
    end
  end

  def test_method_result_preserved
    result = @obj.simple_method
    assert_equal "simple result", result

    @test_class.before :simple_method do
      # This hook doesn't modify anything
    end

    result_with_hook = @obj.simple_method
    assert_equal "simple result", result_with_hook
  end

  def test_thread_safety
    threads = []
    results = []

    10.times do |i|
      threads << Thread.new do
        @test_class.before :test_method do |param1, param2|
          [param1 + i.to_s, param2]
        end
        results << @obj.test_method("test", "value")
      end
    end

    threads.each(&:join)
    assert_equal 10, results.length
  end
end