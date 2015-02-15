module ThreatFarmModel

  def self.process_command_line

    ###################################################
    ## Print out the command line options

    debug_me("#{$OPTIONS[:model_name]}") { :ARGV }  if $debug

    $threat_types         = [""]
    $OPTIONS[:real_time]  = nil    # default to user's selection man-in-the-loop
    
    unless  ARGV.empty?

      $threat_types       = Array.new
      
      ARGV.each do | cli_parm |
      
        case cli_parm.downcase
          when "--sim-time" then
            $OPTIONS[:real_time] = false
          when "--real-time" then
            $OPTIONS[:real_time] = true
          else
            $threat_types << cli_parm.dup
        end
        
      end ## end of ARGV.each do | cli_parm |
      
      $threat_types.map {|a_parm| a_parm.upcase!}
      
    end ## end of unless  ARGV.empty?
    
  end ## end of def self.proccess_command_line
end ## end of module ThreatFarmModel



