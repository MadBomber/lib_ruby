#!/usr/bin/env ruby
# Examples of injecting Hookable into third-party classes

require_relative '../hookable'
require_relative '../hookable_injector'

# Simulate a third-party gem class
class ThirdPartyClass
  def process_data(data)
    puts "Processing: #{data}"
    data.upcase
  end
  
  def calculate(x, y)
    puts "Calculating: #{x} + #{y}"
    x + y
  end
  
  private
  
  def internal_method(msg)
    puts "Internal: #{msg}"
    msg.reverse
  end
end

puts "=== Approach 1: Direct Monkey Patching ==="

# Direct inclusion (affects the class globally)
ThirdPartyClass.include Hookable

# Add hooks from your application code
ThirdPartyClass.before :process_data do |data|
  puts "BEFORE: Validating data: #{data}"
  data.strip  # Clean the data
end

ThirdPartyClass.after :process_data do |result|
  puts "AFTER: Result logged: #{result}"
end

ThirdPartyClass.around :calculate do |x, y, &block|
  puts "AROUND: Starting calculation"
  start_time = Time.now
  result = block.call
  end_time = Time.now
  puts "AROUND: Calculation took #{(end_time - start_time) * 1000}ms"
  result
end

obj1 = ThirdPartyClass.new
result1 = obj1.process_data("  hello world  ")
puts "Result: #{result1}\n\n"

result2 = obj1.calculate(5, 3)
puts "Result: #{result2}\n\n"

# Clear hooks for next example
ThirdPartyClass.clear_hooks(:process_data)
ThirdPartyClass.clear_hooks(:calculate)

puts "=== Approach 2: Using HookableInjector ==="

# Using the injector for cleaner syntax
HookableInjector.inject_into(ThirdPartyClass) do
  before :process_data do |data|
    puts "INJECTOR BEFORE: Preprocessing #{data}"
    data.downcase
  end
  
  after :process_data do |result|
    puts "INJECTOR AFTER: Postprocessing #{result}"
  end
  
  around :calculate do |x, y, &block|
    puts "INJECTOR AROUND: Wrapping calculation"
    result = block.call
    puts "INJECTOR AROUND: Calculation complete"
    result * 2  # Double the result
  end
end

obj2 = ThirdPartyClass.new
result3 = obj2.process_data("MIXED CASE")
puts "Result: #{result3}\n\n"

result4 = obj2.calculate(10, 5)
puts "Result: #{result4}\n\n"

puts "=== Approach 3: Using Refinements (Scoped) ==="

# Create a refinement module
MyRefinements = HookableInjector.inject_with_refinement(ThirdPartyClass) do
  before :process_data do |data|
    puts "REFINEMENT BEFORE: Scoped preprocessing"
    data
  end
  
  after :process_data do |result|
    puts "REFINEMENT AFTER: Scoped postprocessing"
  end
end

# Without using the refinement
puts "Without refinement:"
obj3 = ThirdPartyClass.new
obj3.process_data("test")

puts "\nWith refinement:"
# Using the refinement in a specific context
class ScopedProcessor
  using MyRefinements
  
  def self.process_with_hooks
    obj = ThirdPartyClass.new
    obj.process_data("scoped test")
  end
end

ScopedProcessor.process_with_hooks

puts "\n=== Hook Management ==="

# Show hook introspection
hooks = ThirdPartyClass.hooks_for(:process_data)
puts "Current hooks for process_data:"
puts "  Before hooks: #{hooks[:before].length}"
puts "  After hooks: #{hooks[:after].length}"
puts "  Around hooks: #{hooks[:around].length}"

# Example of removing specific hooks
puts "\nClearing before hooks..."
ThirdPartyClass.clear_hooks(:process_data, :before)

hooks_after_clear = ThirdPartyClass.hooks_for(:process_data)
puts "After clearing before hooks:"
puts "  Before hooks: #{hooks_after_clear[:before].length}"
puts "  After hooks: #{hooks_after_clear[:after].length}"
puts "  Around hooks: #{hooks_after_clear[:around].length}"