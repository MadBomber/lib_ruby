module BatteryFarmModel

  ##########################################
  ## Standard MonteCarlo Message Handlers ##
  ##########################################

	def self.init_case(header=nil, message=nil)
	  puts "MonteCarlo#init_case received by:"
	  pp $run_peer_record
	  pp $run_model_record

	  $sim_time.reset

    $active_threats = Hash.new
    $do_not_engage  = Hash.new


	  init_case_complete = InitCaseComplete.new
#  	  init_case_complete.case_number_ = message.case_number_
	  init_case_complete.publish
	end

end
