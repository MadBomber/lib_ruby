module RadarFarmModel

  ##########################################
  ## Standard MonteCarlo Message Handlers ##
  ##########################################

	def self.init_case(header=nil, message=nil)
	  puts "MonteCarlo#init_case received by:"
	  pp $run_peer_record
	  pp $run_model_record

	  $sim_time.reset
	  
	  # Seed the normal distribution
	  srand(2000042520011117)

	  init_case_complete = InitCaseComplete.new
#  	  init_case_complete.case_number_ = message.case_number_
	  init_case_complete.publish
	end

end
