#!/usr/bin/env ruby
# Simple examples of injecting Hookable into third-party classes

require_relative '../hookable'
require_relative '../hookable_injector'

# Simulate a third-party gem class that you cannot modify
class ThirdPartyService
  def send_email(to, subject, body)
    puts "Sending email to #{to}"
    puts "Subject: #{subject}"
    puts "Body: #{body}"
    { status: "sent", id: rand(1000..9999) }
  end
  
  def log_event(event, data)
    puts "Event: #{event}, Data: #{data}"
    "logged"
  end
end

puts "=== Original Third-Party Class (no hooks) ==="
service = ThirdPartyService.new
result = service.send_email("user@example.com", "Test", "Hello World")
puts "Result: #{result}"
puts

puts "=== Approach 1: Direct Monkey Patching ==="
# This approach modifies the class globally
ThirdPartyService.include Hookable

# Add validation hook
ThirdPartyService.before :send_email do |to, subject, body|
  puts "HOOK: Validating email to #{to}"
  raise "Invalid email" unless to.include?("@")
  [to, subject, body]  # Return array to preserve parameters
end

# Add logging hook
ThirdPartyService.after :send_email do |result|
  puts "HOOK: Email sent with ID #{result[:id]}"
end

service2 = ThirdPartyService.new
result2 = service2.send_email("admin@company.com", "Report", "Daily report attached")
puts "Result: #{result2}"
puts

puts "=== Approach 2: Using HookableInjector ==="
# Clear previous hooks for clean example
ThirdPartyService.clear_hooks(:send_email)

# Use injector for cleaner syntax
HookableInjector.inject_into(ThirdPartyService) do
  before :send_email do |to, subject, body|
    puts "INJECTOR: Pre-processing email"
    # Sanitize subject
    sanitized_subject = subject.gsub(/[<>]/, "")
    [to, sanitized_subject, body]
  end
  
  around :send_email do |to, subject, body, &block|
    puts "INJECTOR: Starting email send process"
    start_time = Time.now
    result = block.call
    end_time = Time.now
    puts "INJECTOR: Email sent in #{((end_time - start_time) * 1000).round(2)}ms"
    result
  end
  
  after :send_email do |result|
    puts "INJECTOR: Updating analytics for email #{result[:id]}"
  end
end

service3 = ThirdPartyService.new
result3 = service3.send_email("test@example.com", "Alert <urgent>", "System alert")
puts "Result: #{result3}"
puts

puts "=== Approach 3: Class Extension Pattern ==="
# This approach creates a wrapper without modifying the original class
class EnhancedThirdPartyService < ThirdPartyService
  include Hookable
  
  # Add hooks in the subclass
  before :log_event do |event, data|
    puts "ENHANCED: Timestamping event #{event}"
    [event, data.merge(timestamp: Time.now)]
  end
  
  after :log_event do |result|
    puts "ENHANCED: Event processing complete"
  end
end

enhanced_service = EnhancedThirdPartyService.new
enhanced_service.log_event("user_login", { user_id: 123 })
puts

puts "=== Hook Management ==="
hooks = ThirdPartyService.hooks_for(:send_email)
puts "Current hooks for send_email:"
puts "  Before hooks: #{hooks[:before].length}"
puts "  After hooks: #{hooks[:after].length}"
puts "  Around hooks: #{hooks[:around].length}"