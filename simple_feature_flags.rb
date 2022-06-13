# lib/ruby/simple_feature_flags.rb
#
# See: https://blog.appsignal.com/2022/06/08/add-feature-flags-in-ruby-on-rails-with-flipper.html
#
# For serious work use the "gem install flipper"
#

=begin
  Usage:

  In the shell ...

  export SAY_HELLO='xxx'  # any value means it is enabled
  unset SAY_HELLO         # no value means it is NOT enavled

  In the code ...

  require 'simple_feature_flags'
  include SimpleFeatureFlags

  ...

  if feature_enabled? :say_hello
    puts "Hello"
  end

=end

module SimpleFeatureFlags
  def feature_enabled?(feature_name)
    ENV[feature_name&.to_s.upcase]
  end
end
