# ~/lib/ruby/call_tracer.rb

class CallTracer
  def initialize(
        log_file=nil,   # String: filename
        search: nil,    # String: substring in path to log
        here:   '',     # String: path prefix to remove
        indent: '  ',   # String: indention character(s)
        editor: 'subl'  # Sring: name of a text editor
      )  
    if log_file.nil?
      @log = STDOUT
    else
      @log = File.open(log_file, 'w')
    end

    @search       = search
    @here         = here
    @indent       = indent
    @trace_point  = nil
    @call_stack   = []
  end

  def start
    @trace_point = TracePoint.new(:call, :return) do |tp|
      location = "#{@editor} #{tp.path.gsub(@here,'.')}:#{tp.lineno}"
      case tp.event
      when :call
        event = "#{@indent * @call_stack.size}#{tp.defined_class}##{tp.method_id} #{location}"
        @call_stack.push([tp.defined_class, tp.method_id])
      when :return
        last_call = @call_stack.pop
        return_value = tp.return_value.inspect
        # Ensure that we are returning from the correct method.
        if last_call == [tp.defined_class, tp.method_id]
          event = "#{@indent * @call_stack.size}#{last_call[0]}##{last_call[1]} returned #{return_value} #{location}"
        end
        event = ""
      end
      
      if !@search.nil? && !event.empty? && location.include?(@search)
        @log.puts event
      end
    end

    @trace_point.enable
  end

  def stop
    @trace_point.disable if @trace_point
  end
end

