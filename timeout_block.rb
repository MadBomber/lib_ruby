# ~/lib/ruby/timeout_block.rb

require 'timeout'

def timeout_block(seconds, &block)
  begin
    Timeout.timeout(seconds) do
      block.call
    end
  rescue Timeout::Error
    nil
  end
end
