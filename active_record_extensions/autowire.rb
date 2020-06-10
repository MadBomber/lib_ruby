# lib/ruby/autowire.rb
#
# An interesting way to add ability to access
# the keys of a hash/json column directly.

module ActiveRecordExtension
  extend ActiveSupport::Concern

  # add your class methods here
  module ClassMethods
    # Creates accessor methods (generic getter and setter) on results hash
    # for all fields passed in.  Does not work if 'results' field does not
    # exist as type json, and assumes that results hash does not have
    # symbolized keys.
    def autowire_results_fields(*fields)
      fields = [fields] unless fields.is_a?(Array)
      instance_eval do
        fields.each do |field|
          define_method(field.to_s) do
            self.results ||= {}
            self.results[field.to_s]
          end
          define_method("#{field}=") do |val|
            self.results ||= {}
            self.results[field.to_s] = val
          end
        end
      end
    end
  end
end

# include the extension
ActiveRecord::Base.send(:include, ActiveRecordExtension)
