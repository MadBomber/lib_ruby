######################################################
###
##  File:  debugging_stuff.rb
##  Desc:  The programmer's friends
#

$EM_DEBUG		= true

$debug_label = "RMMRBM_006"

if $EM_DEBUG

  require 'debug_me'

else

  def debug_me(*args, &block)
    nil
  end

end


#debug_me(:tag=>"DEBUG INITIALIZED", :trace=>true)


