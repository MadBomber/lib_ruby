require 'minitest/autorun'
require_relative '../hookable'
require_relative '../hookable_injector'

class HookableInjectorTest < Minitest::Test
  def setup
    # Create a fresh third-party class for each test
    @third_party_class = Class.new do
      def process(data)
        "processed: #{data}"
      end
      
      def calculate(x, y)
        x + y
      end
    end
  end

  def test_direct_injection_with_monkey_patch
    # Direct inclusion
    @third_party_class.include Hookable
    
    executed = false
    @third_party_class.before :process do |data|
      executed = true
      data
    end
    
    obj = @third_party_class.new
    obj.process("test")
    
    assert executed, "Hook should have been executed after direct injection"
  end

  def test_injection_via_hookable_injector
    executed_before = false
    executed_after = false
    
    HookableInjector.inject_into(@third_party_class) do
      before :process do |data|
        executed_before = true
        [data.upcase]  # Return array to modify parameters
      end
      
      after :process do |result|
        executed_after = true
      end
    end
    
    obj = @third_party_class.new
    result = obj.process("test")
    
    assert executed_before, "Before hook should have been executed"
    assert executed_after, "After hook should have been executed"
    assert_equal "processed: TEST", result
  end

  def test_hook_context_methods
    context = HookableInjector.inject_into(@third_party_class) do
      before :process do |data|
        data
      end
    end
    
    # Test that context provides access to hook management
    hooks = context.hooks_for(:process)
    assert_equal 1, hooks[:before].length
    assert_equal 0, hooks[:after].length
    
    # Test clearing hooks through context
    context.clear_hooks(:process, :before)
    hooks_after_clear = context.hooks_for(:process)
    assert_equal 0, hooks_after_clear[:before].length
  end

  def test_monkey_patch_injection
    # Test direct monkey patching approach
    @third_party_class.class_eval do
      include Hookable
      
      before :process do |data|
        [data.upcase]  # Return array to modify parameters
      end
    end
    
    obj = @third_party_class.new
    result = obj.process("hello")
    assert_equal "processed: HELLO", result
  end

  def test_multiple_hooks_via_injector
    execution_order = []
    
    HookableInjector.inject_into(@third_party_class) do
      before :process do |data|
        execution_order << :before1
        data
      end
      
      before :process do |data|
        execution_order << :before2
        data
      end
      
      after :process do |result|
        execution_order << :after1
      end
      
      around :process do |data, &block|
        execution_order << :around_before
        result = block.call
        execution_order << :around_after
        result
      end
    end
    
    obj = @third_party_class.new
    obj.process("test")
    
    expected_order = [:before1, :before2, :around_before, :around_after, :after1]
    assert_equal expected_order, execution_order
  end

  def test_injection_preserves_existing_functionality
    original_result = @third_party_class.new.calculate(5, 3)
    
    HookableInjector.inject_into(@third_party_class) do
      before :calculate do |x, y|
        [x, y]  # Don't modify parameters
      end
    end
    
    hooked_result = @third_party_class.new.calculate(5, 3)
    assert_equal original_result, hooked_result
  end

  def test_injection_into_already_hookable_class
    # First injection
    HookableInjector.inject_into(@third_party_class) do
      before :process do |data|
        data.upcase
      end
    end
    
    # Second injection should not break anything
    HookableInjector.inject_into(@third_party_class) do
      after :process do |result|
        # Just add another hook
      end
    end
    
    hooks = @third_party_class.hooks_for(:process)
    assert_equal 1, hooks[:before].length
    assert_equal 1, hooks[:after].length
  end
end