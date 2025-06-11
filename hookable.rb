# ~/lib/ruby/hookable.rb
# A way of adding before, after, and around hooks to methods in a class
# After I wrote this I found out that there is an old gem "hook" that
# provides similar functionality. https://github.com/moonmaster9000/hook

module Hookable
  def self.included(base)
    base.extend(ClassMethods)
    base.instance_variable_set(:@hooks, Hash.new { |h, k| h[k] = { before: [], after: [], around: [] } })
    base.instance_variable_set(:@hook_mutex, Mutex.new)
  end

  module ClassMethods
    def before(method_name, &block)
      add_hook(method_name, :before, block)
    end

    def after(method_name, &block)
      add_hook(method_name, :after, block)
    end

    def around(method_name, &block)
      add_hook(method_name, :around, block)
    end

    def remove_hook(method_name, hook_type, &block)
      @hook_mutex.synchronize do
        @hooks[method_name][hook_type].delete(block)
      end
    end

    def clear_hooks(method_name, hook_type = nil)
      @hook_mutex.synchronize do
        if hook_type
          @hooks[method_name][hook_type].clear
        else
          @hooks[method_name] = { before: [], after: [], around: [] }
        end
      end
    end

    def hooks_for(method_name)
      @hooks[method_name].dup
    end

    private

    def add_hook(method_name, hook_type, hook_block)
      raise ArgumentError, "Block required for hook" unless hook_block
      raise ArgumentError, "Method '#{method_name}' does not exist" unless method_defined?(method_name) || private_method_defined?(method_name)

      @hook_mutex.synchronize do
        # Only redefine method if this is the first hook for this method
        if @hooks[method_name].values.all?(&:empty?)
          define_hookable_method(method_name)
        end
        @hooks[method_name][hook_type] << hook_block
      end
    end

    def define_hookable_method(method_name)
      visibility = method_visibility(method_name)
      original_method_name = "#{method_name}_without_hooks"

      alias_method original_method_name, method_name

      define_method(method_name) do |*args, &block|
        hooks = self.class.instance_variable_get(:@hooks)[method_name]

        # Execute before hooks
        modified_args = args
        hooks[:before].each do |hook|
          result = instance_exec(*modified_args, &hook)
          modified_args = result if result.is_a?(Array)
        end

        # Execute around hooks (nested)
        execution_proc = proc { send(original_method_name, *modified_args, &block) }
        hooks[:around].reverse.each do |hook|
          outer_proc = execution_proc
          execution_proc = proc {
            instance_exec(*modified_args) {
              hook.call(*modified_args) {
                outer_proc.call
              }
            }
          }
        end

        result = execution_proc.call

        # Execute after hooks
        hooks[:after].each do |hook|
          instance_exec(result, &hook)
        end

        result
      end

      send(visibility, method_name) if visibility != :public
    end

    def method_visibility(method_name)
      return :private if private_method_defined?(method_name)
      return :protected if protected_method_defined?(method_name)
      :public
    end
  end
end
