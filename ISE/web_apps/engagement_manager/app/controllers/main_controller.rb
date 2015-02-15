class MainController < ApplicationController
  ####################################
  def self.update_time(frame_count, run_id)

    $run_record.id = run_id

    if frame_count <= 1
    
      ########################################
      ##          RESET SIMULATION          ##
      ########################################
      # Reset time
      $sim_time.reset

      # Reset all objects
      EmThreatsController.reset
      EmQueuesController.reset

      # Display reset message
      if $EM_DEBUG
        puts '*' * 80
        puts((' ' * 35) + 'RESET SIM')
        puts '*' * 80
      end
    end ## if frame_count <= 1
    
    $sim_time.offset = frame_count
      
    puts "FrameCount: #{frame_count} Time: #{$sim_time.now}" if $sim_time.now % 10 < 1

    
    return :ok
  end ## def update_time(frame_count, run_id)
  
end ## class MainController < ApplicationController
