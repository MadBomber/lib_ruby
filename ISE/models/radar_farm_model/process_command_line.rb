module RadarFarmModel

  def self.process_command_line

    ###################################################
    ## Print out the command line options

    debug_me("#{$OPTIONS[:model_name]}") { :ARGV }    if $debug

    if ARGV.empty?
      $radar_types = ["lower", "upper", "search"]
    else
      $radar_types = ARGV.map {|a| a.downcase}
    end

  end ## end of def self.proccess_command_line

end



