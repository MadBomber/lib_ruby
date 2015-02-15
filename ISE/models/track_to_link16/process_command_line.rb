module TrackToLink16

  def self.process_command_line

    ###################################################
    ## Print out the command line options

    debug_me("#{$OPTIONS[:model_name]}") { :ARGV }  if $debug

  end ## end of def self.proccess_command_line

end



