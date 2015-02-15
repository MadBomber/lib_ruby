require 'test_helper'

class EmInterceptorTest < Test::Unit::TestCase
  
  def setup
    @init_hash = {
      'label'          => 'test_interceptor',
      'launcher_label' => 'test_launcher',
      'threat_label'   => 'test_threat',
      'launch_time'    => 0.0,
      'intercept_time' => 60.0,
      'status'         => :waiting
    }
    
    @bad_init_hash = {
      'foo' => 'bar'
    }
    
    @interceptor = EmInterceptor.new(init_hash)
  end
  
  def good_attribute_error_string(type, proper_value, bad_value)
    return "Interceptor #{type} was improperly set, expected '#{proper_value}' but got '#{bad_value}'."
  end
  
  def good_attribute_assertion(thing)
    input = @init_hash[thing]
            
    result = @interceptor.method(thing.call)
        
    assert(input == result, good_attribute_error_string(thing, input, result))
  end
  
  test "sets interceptor's label" do
    good_attribute_assertion('label')
  end
  
  test "sets interceptor's launcher label" do
    good_attribute_assertion('launcher_label')
  end
  
  test "sets interceptor's threat label" do
    good_attribute_assertion('threat_label')
  end
  
  test "sets interceptor's launch time" do
    good_attribute_assertion('launch_time')
  end
  
  test "sets interceptor's intercept time" do
    good_attribute_assertion('intercept_time')
  end
  
  test "sets interceptor's status" do
    good_attribute_assertion('status')
  end
  
  test "doesn't set incorrect interceptor attributes" do
    assert_raises(StandardError) do
      bad_interceptor = EmInterceptor.new(@bad_init_hash)
    end
  end
  
end
