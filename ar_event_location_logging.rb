ActiveSupport::Notifications.subscribe('sql.active_record') do |name, started, finished, unique_id, data|
  call_stack      = caller
  app_call_stack  = call_stack.select { |line| line.start_with?(Rails.root.to_s) }
  caller_location = app_call_stack.first

  Rails.logger.info "ActiveRecord SQL Event: #{data[:sql]} | Caller: #{caller_location}"
end
