module BatteryFarmModel

  def self.process_command_line

    ###################################################
    ## Print out the command line options

    $OPTIONS[:auto_engage_tbm] = nil
    $OPTIONS[:auto_engage_abt] = nil
   
    unless ARGV.empty?
      inputs = ARGV.map {|a| a.downcase}
      
      inputs.each do |input|
      
        case input
          when "--auto-tbm" then
            $OPTIONS[:auto_engage_tbm] = true
          when "--auto-abt" then
            $OPTIONS[:auto_engage_abt] = true
        end
      end
    end
    
=begin
    if ARGV.empty?
      $battery_types = ["lower", "upper"]
    else
      $battery_types = ARGV.map {|a| a.downcase}
    end
=end

  end ## end of def self.proccess_command_line

end



