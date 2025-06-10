# Hookable Injection Patterns

This document demonstrates several ways to inject the Hookable module into third-party classes that you cannot modify directly.

## Pattern 1: Direct Monkey Patching

The simplest approach is to directly include Hookable into the third-party class:

```ruby
require 'hookable'
require 'third_party_gem'

# Include Hookable into the third-party class
ThirdPartyClass.include Hookable

# Add hooks from your application
ThirdPartyClass.before :some_method do |param|
  puts "Before hook: validating #{param}"
  [param.upcase]  # Return array to modify parameters
end

ThirdPartyClass.after :some_method do |result|
  puts "After hook: result was #{result}"
end

# Now all instances use the hooks
obj = ThirdPartyClass.new
obj.some_method("hello")  # Will trigger hooks
```

**Pros:**
- Simple and direct
- Works immediately on all instances
- Full access to all hook types

**Cons:**
- Modifies the class globally
- Could conflict with other gems
- Cannot be scoped or undone easily

## Pattern 2: Using HookableInjector

Use the provided HookableInjector for cleaner syntax:

```ruby
require 'hookable_injector'
require 'third_party_gem'

# Inject hooks using the helper
HookableInjector.inject_into(ThirdPartyClass) do
  before :some_method do |param|
    puts "Injected before hook"
    [param.strip]  # Clean the parameter
  end
  
  after :some_method do |result|
    puts "Injected after hook"
  end
  
  around :some_method do |param, &block|
    puts "Starting operation"
    result = block.call
    puts "Operation complete"
    result
  end
end
```

**Pros:**
- Clean, block-based syntax
- Returns a context object for hook management
- Same power as direct inclusion

**Cons:**
- Still modifies the class globally
- Adds a dependency

## Pattern 3: Subclass Extension

Create a subclass that includes Hookable:

```ruby
require 'hookable'
require 'third_party_gem'

class MyEnhancedClass < ThirdPartyClass
  include Hookable
  
  before :some_method do |param|
    puts "Enhanced before hook"
    [param.downcase]
  end
  
  after :some_method do |result|
    puts "Enhanced after hook"
  end
end

# Use the enhanced class instead
obj = MyEnhancedClass.new
obj.some_method("HELLO")  # Will trigger hooks
```

**Pros:**
- Doesn't modify the original class
- Can coexist with original class
- Clear inheritance relationship

**Cons:**
- Must use the subclass everywhere
- Doesn't help with existing instances
- May not work if class is instantiated by framework

## Pattern 4: Instance-Level Decoration

Decorate specific instances:

```ruby
require 'hookable'
require 'third_party_gem'

# Create a decorator module
module ThirdPartyEnhancements
  def self.enhance(instance)
    # Extend the singleton class
    instance.singleton_class.include Hookable
    
    instance.singleton_class.before :some_method do |param|
      puts "Instance-level hook"
      [param.strip]
    end
    
    instance
  end
end

# Enhance specific instances
obj = ThirdPartyClass.new
enhanced_obj = ThirdPartyEnhancements.enhance(obj)
enhanced_obj.some_method("  hello  ")  # Will trigger hooks

# Regular instances are unaffected
regular_obj = ThirdPartyClass.new
regular_obj.some_method("world")  # No hooks
```

**Pros:**
- Very targeted - only affects specific instances
- Original class remains untouched
- Can be applied selectively

**Cons:**
- More complex implementation
- Only works on instances you control
- Singleton class complexity

## Hook Management

All patterns support hook management:

```ruby
# View current hooks
hooks = ThirdPartyClass.hooks_for(:some_method)
puts "Before hooks: #{hooks[:before].length}"
puts "After hooks: #{hooks[:after].length}"
puts "Around hooks: #{hooks[:around].length}"

# Clear specific hook types
ThirdPartyClass.clear_hooks(:some_method, :before)

# Clear all hooks for a method
ThirdPartyClass.clear_hooks(:some_method)
```

## Important Notes

1. **Parameter Modification**: Before hooks can modify parameters by returning an Array:
   ```ruby
   before :method do |param1, param2|
     [param1.upcase, param2.strip]  # Must return array
   end
   ```

2. **Thread Safety**: The Hookable module uses a Mutex for thread-safe hook management.

3. **Method Existence**: Hooks can only be added to methods that already exist on the class.

4. **Private Methods**: Hooks can be added to private methods and will respect visibility.

## Recommended Approach

For most use cases, **Pattern 1 (Direct Monkey Patching)** or **Pattern 2 (HookableInjector)** are recommended because they:
- Are simple to implement
- Work with all instances
- Provide full hook functionality
- Have minimal overhead

Use **Pattern 3 (Subclass Extension)** when you want to avoid modifying the original class but can control instantiation.

Use **Pattern 4 (Instance-Level Decoration)** for very targeted enhancements where you only want to affect specific instances.