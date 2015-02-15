require 'debug_me'

module EmFeeder

  ###############################################
  ## A generic callback to dump incoming messages
  
  def self.feed_message(a_header, a_message=nil)
  
    unless $unrecoverable_post_error
    
      feed_the_message = true
    
      if $debug
        puts "Start: "+"="*60
        puts "feed_message callback in the EmFeeder just received this message:"
        puts "#### HEADER ####"
        puts a_header.to_s
        pp a_header
        if a_message
          puts "#### MESSAGE ####"
          puts a_message.to_s
          pp a_message
        end
        puts "End:" + "-"*60
        $stdout.flush   ## default ruby buffer size is 32k; default only flushes when buffer full
      end ## end of if $debug
      
      field_values_hash = a_message.to_h.merge(
        { # Merging selected fields from the message header
          "run_id_"       => a_header.run_id_,
          "frame_count_"  => a_header.frame_count_
        }
      )
      
      msg_name = a_message.class.to_s
      
      # NOTE: This 'if' block is what makes EmFeeder different from WebAppFeeder.
      #       The EngagementManager can not process post events fast enought to
      #       satisfy user response expectations.  By cutting the number of
      #       start frame messages, we cut the size of the message backlog within EM.
      if 'StartFrame' == msg_name
        feed_the_message = false if 0 == (a_header.frame_count_ % 2)  ## even frames
        debug_me {['a_header.frame_count_.class', 'a_header.frame_count_', :feed_the_message]} if $debug
      end
      
      if feed_the_message
        begin
          $web_app[msg_name].post( field_values_hash ) { |response, thing|
            unless 200 == response.code
              puts "Bad Post Response Code: #{response.code} msg_name: #{msg_name}, url: #{$web_app.url}"
              puts "thing: #{thing.inspect}"
            end
          }
        rescue Exception => e
          debug_me("Abnormal Termination #{e}"){:$web_app}
          # $unrecoverable_post_error = true
        end
      end
    end # unrecoverable error
    
  end ## end of def self.feed_message(a_header, a_message=nil)

end

