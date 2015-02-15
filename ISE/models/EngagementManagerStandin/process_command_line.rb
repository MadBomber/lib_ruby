module EngagementManagerStandin

  def self.process_command_line

    ###################################################
    ## Print out the command line options

    debug_me("#{$OPTIONS[:model_name]}") { :ARGV } if $debug

    $OPTIONS[:auto_engage_tbm] = false
    $OPTIONS[:auto_engage_abt] = false
    
    unless ARGV.empty?
      $inputs = ARGV.map {|a| a.downcase}

      $inputs.each do |input|
        case input
        when "--auto-tbm" then
          $OPTIONS[:auto_engage_tbm] = true
        when "--auto-abt" then
          $OPTIONS[:auto_engage_abt] = true
        end
      end
    end


  end ## end of def self.proccess_command_line
end ## end of module EngagementManagerStandin



