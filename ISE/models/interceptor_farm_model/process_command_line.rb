module InterceptorFarmModel

  def self.process_command_line

=begin

    ############################################
    ## process command line parameters

    $OPTIONS[:message] = nil

    ARGV.options do |o|

      o.on("-m", "--message=name[,name]*", String, "Message Name(s) to log")      { |$OPTIONS[:message]| }
      o.on("-#", "Delimits the start of IseRubyModel options")      { |x| }
      o.parse!

    end ## end of ARGV.options do

    if $OPTIONS[:message]
      $log_message_names = $OPTIONS[:message].split(',')
      puts "Begin logging the following messages:"
      $log_message_names.each do |lmn|
        puts "\t#{lmn}"
      end
      puts
    end

    ################################################
    ## require the message libraries to be used in
    ## this IseRubyModel


    # require 'TruthTargetStates'

    $log_message_names.each do |message_name|
      require message_name
    end

=end


    ###################################################
    ## Print out the command line options

    if $debug or $verbose
      pp ARGV
      puts '='*60
    end


  end ## end of def self.proccess_command_line

end



