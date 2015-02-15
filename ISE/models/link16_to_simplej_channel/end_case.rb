module Link16ToSimplejChannel

  ##########################################
  ## Standard MonteCarlo Message Handlers ##
  ##########################################


  def self.end_case(header=nil, message=nil)
	  debug_me "MonteCarlo#end_case"   if $debug
	  # ... do stuff ...
	  end_case_complete = EndCaseComplete.new
#   	end_case_complete.case_number_ = message.case_number_

	  end_case_complete.publish
	  
	end

end
