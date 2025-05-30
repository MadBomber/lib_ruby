#~/lib/ruby/thread_pool.rb
# See: https://gist.github.com/ahoward/6206f09777c746fcf691bdcf1f46ca54
#

require 'thread'
require 'time'
require 'json'

class ThreadPool
  class Error < ::StandardError; end

  DEFAULT = {
    size: 8,
    wip: 4242,
  }

  def initialize(*args, **kws, &block)
    @process = kws.fetch(:process){ default_process }
    @success = kws.fetch(:success){ default_success }
    @failure = kws.fetch(:failure){ default_failure }

    @run = kws.fetch(:run){ default_run }

    @size = kws.fetch(:size){ DEFAULT.fetch(:size) }

    wip = kws.fetch(:wip){ DEFAULT.fetch(:wip) }
    wip = [wip - @size, 1].max

    @q = Queue.new(wip:)
    @m = Mutex.new

    io = kws.fetch(:log){ $stderr }
    @log = Log.new(io:)

    start_handler!
    start_workers!

    if block
      configure!(&block)
      run!
      wait!
    end
  end

  def configure!(&block)
    block.call(self)
  end

  def run!(*args, **kws)
    @run.call(*args, **kws)
  end

  def start_handler!
    return if @handler

    @handler = Thread.new do
      Thread.current.abort_on_exception = true

      loop do
        msg = @q.o.pop
        break if msg == @q.x
        sleep if Thread.current[:sleep]

        type, args, kws = msg

        case type
          when :success
            @success.call(*args, **kws)
          when :failure
            @failure.call(*args, **kws)
          else
            raise ArgumentError.new(msg.class.name)
        end
      end
    end
  end

  def start_workers!
    return if @workers

    @workers = []

    @size.times do |number|
      @workers.push(
        Thread.new do
          Thread.current.abort_on_exception = true

          loop do
            msg = @q.i.pop
            break if msg == @q.x
            sleep if Thread.current[:sleep]

            type, args, kws = msg

            case type
              when :process
                @process.call(*args, **kws)
              else
                raise ArgumentError.new(msg.class.name)
            end
          end

          @q.o.push(@q.x)
        end
      )
    end

    @workers
  end

  def synchronize(*args, **kws, &block)
    @m.synchronize(*args, **kws, &block)
  end

  alias sync synchronize

  def threads
    @workers + [@handler]
  end

  def stop
    unless stopped?
      @size.times{ @q.i.push(@q.x) }
      @q.i.close
    end
  end

  def stopped?
    @q.i.closed?
  end

  def stop!
    stop
    threads.each{|thread| thread.kill}
  end

  def debug(&block)
    sync do
      threads.each do |thread|
        thread[:sleep] = Thread.current != thread
      end

      block.call

      threads.each do |thread|
        thread[:sleep] = false
        thread.run
      end
    end
  end

  def wait
    stop
    threads.each{|thread| thread.join}
    log.wait
  end

  alias wait! wait

  def exit(status = 0)
    stop
    wait
    Kernel.exit(status)
  end

#
  def default_process
    noop
  end

  def default_success
    proc{|*args, **kws| log.success(*args, **kws)}
  end

  def default_failure
    proc{|*args, **kws| log.failure(*args, **kws)}
  end

  def default_run
    noop
  end

  def noop
    proc{|*args, **kws|}
  end

#
  def process(&block)
    if block
      @process = block
    end

    @process
  end

  def process!(*args, **kws)
    @q.i.push [:process, args, kws]
  end

  def process_all!(*argv)
    argv.each{|arg| process!(arg)}
  end

  def process=(process)
    @process = process
  end

  def success(&block)
    if block
      @success = block
    end

    @success
  end

  def success!(*args, **kws)
    @q.o.push [:success, args, kws]
  end

  def success=(success)
    @success = success
  end

  def failure(&block)
    if block
      @failure = block
    end

    @failure
  end

  def failure!(*args, **kws)
    @q.o.push [:failure, args, kws]
  end

  def failure=(failure)
    @failure = failure
  end

  def run(&block)
    if block
      @run = block
    end

    @run
  end

  def run=(run)
    @run = run
  end

#
  class Queue
    attr_reader :wip, :i, :o, :x

    def initialize(wip: 4242)
      @wip = wip.to_i
      @i = ::SizedQueue.new(@wip)
      @o = ::Queue.new
      @x = ::Object.new
    end
  end

#
  class Log
    def initialize(io: $stderr)
      @io = io
      @q = ::Queue.new

      @writer = Thread.new do
        Thread.current.abort_on_exception = true

        loop do
          msg = @q.pop
          break if msg == :done
          level, args, kws = msg
          log(level, *args, **kws)
        end
      end
    end

    def wait
      @q.push(:done)
      @writer.join
    end

    def success(*args, **kws)
      @q.push([:success, args, kws])
    end

    def failure(*args, **kws)
      @q.push([:failure, args, kws])
    end

    def warning(*args, **kws)
      @q.push([:warning, args, kws])
    end

    def message(*args, **kws)
      @q.push([:message, args, kws])
    end

    def log(level, *args, **kws)
      return unless @io

      level = level.to_s.strip.downcase.to_sym

      objs = args.map{|arg| arg}
      objs << kws if kws.size > 0

      color = Colors[level] || Colors[:default]

      label = level.to_s.upcase
      time = Time.now.utc.iso8601(2)

      banner = "### #{ label } @ #{ time }"

      if @io.tty?
        ansi = [
          Ansi.fetch(:bold),
          Ansi.fetch(color),
          banner,
          Ansi.fetch(:clear),
        ]

        banner = ansi.join
      end

      @io.write(banner)
      @io.write("\n")

      objs.each do |obj|
        jsonl = obj.to_json.gsub(/\n/, '')

        @io.write(jsonl)
        @io.write("\n")
      end
    end

    Colors = {
      :success => :green,
      :failure => :red,
      :warning => :yellow,
      :message => :cyan,
      :default => :blue,
    }

    Ansi = {
      :clear      => "\e[0m",
      :reset      => "\e[0m",
      :erase_line => "\e[K",
      :erase_char => "\e[P",
      :bold       => "\e[1m",
      :dark       => "\e[2m",
      :underline  => "\e[4m",
      :underscore => "\e[4m",
      :blink      => "\e[5m",
      :reverse    => "\e[7m",
      :concealed  => "\e[8m",
      :black      => "\e[30m",
      :red        => "\e[31m",
      :green      => "\e[32m",
      :yellow     => "\e[33m",
      :blue       => "\e[34m",
      :magenta    => "\e[35m",
      :cyan       => "\e[36m",
      :white      => "\e[37m",
      :on_black   => "\e[40m",
      :on_red     => "\e[41m",
      :on_green   => "\e[42m",
      :on_yellow  => "\e[43m",
      :on_blue    => "\e[44m",
      :on_magenta => "\e[45m",
      :on_cyan    => "\e[46m",
      :on_white   => "\e[47m"
    }

    Instance = new

    def Log.instance
      Instance
    end
  end

  def ThreadPool.log(*args, **kws, &block)
    Log.instance
  end

  def log
    @log
  end
end


if $0 == __FILE__

  jobs = [
    {value: 42},
    {value: 42.0},
    {value: 'forty-two'},
  ]

  results = {success:[], failure:[]}

  ThreadPool.new do |tp|
    tp.run do
      jobs.each do |job|
        tp.process!(job:)
      end
    end

    tp.process do |job:|
      if [42, 42.0].include?(job[:value])
        tp.success!(job:)
      else
        tp.failure!(job:)
      end
    end

    tp.failure do |job:|
      tp.log.failure(job:)

      results[:failure].push(job) # <- this is thread safe!
    end

    tp.success do |job:|
      tp.log.success(job:)

      results[:success].push(job) # <- this is thread safe!
    end
  end
end
