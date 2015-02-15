######################################################
###
##  File:  engagement_rules.rb
##  Desc:  Rules of Engagement
#

class EngagementRule
  
  @@rules = Hash.new
  
  def initialize(a_string, &block) 
    if @@rules.include?(a_string)
      log_this "WARNING: Redefined engagement rule: #{a_string}"
    end
    @@rules[a_string] = block
  end  ## end of def initialize
  
  def method_missing
    puts "Don't know how to do that..."
  end
  
end  ## end of class EngagementRule

__END__


Do something like the IseScenario library
