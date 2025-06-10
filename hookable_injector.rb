# ~/lib/ruby/hookable_injector.rb
# External injection of hooks into third-party classes

require_relative 'hookable'

module HookableInjector
  class << self
    def inject_into(klass, &block)
      # Include Hookable if it's not already included
      unless klass.included_modules.include?(Hookable)
        klass.include Hookable
      end
      
      # Create a context for defining hooks externally
      hook_context = HookContext.new(klass)
      hook_context.instance_eval(&block) if block_given?
      hook_context
    end
    
    def inject_with_refinement(klass, &block)
      # For refinements, we'll use monkey patching within the refinement scope
      # This is a simpler approach that works with modern Ruby
      refinement_module = Module.new do
        refine klass do
          # The refinement will just monkey patch the class
          # Include Hookable when the refinement is used
          def self.use_hooks(&hook_block)
            include Hookable unless included_modules.include?(Hookable)
            class_eval(&hook_block) if hook_block
          end
        end
      end
      
      # Set up the hooks if a block is provided
      if block_given?
        # We need to apply the hooks when the refinement is used
        original_block = block
        refinement_module.define_singleton_method(:setup_hooks) do |target_class|
          target_class.include Hookable unless target_class.included_modules.include?(Hookable)
          target_class.class_eval(&original_block)
        end
      end
      
      refinement_module
    end
  end
  
  class HookContext
    def initialize(target_class)
      @target_class = target_class
    end
    
    def before(method_name, &block)
      @target_class.before(method_name, &block)
    end
    
    def after(method_name, &block)
      @target_class.after(method_name, &block)
    end
    
    def around(method_name, &block)
      @target_class.around(method_name, &block)
    end
    
    def clear_hooks(method_name, hook_type = nil)
      @target_class.clear_hooks(method_name, hook_type)
    end
    
    def hooks_for(method_name)
      @target_class.hooks_for(method_name)
    end
  end
end