# frozen_string_literal: true

ENV["APP_ENV"] = "test"

require "webmock"
require_relative "../lib/db"
require_relative "factories"

WebMock.enable!
WebMock.disable_net_connect!(allow_localhost: true)

DB.configure do |c|
  c.pool_size = 1
  c.reap = false
end

class Test
  class Failure < StandardError; end

  include Factories
  include WebMock::API

  if ENV["CI"]
    GREEN = ""
    RED = ""
    RESET = ""
  else
    GREEN = "\e[32m"
    RED = "\e[31m"
    RESET = "\e[0m"
  end

  @@groups = []
  @@seed = nil
  @@name = nil

  i = 0
  while i < ARGV.length
    case ARGV[i]
    when "--seed"
      @@seed = ARGV[i + 1].to_i if i + 1 < ARGV.length
      i += 2
    when "--name"
      @@name = ARGV[i + 1] if i + 1 < ARGV.length
      i += 2
    else
      i += 1
    end
  end

  def self.inherited(c)
    @@groups << c
  end

  def self.run_suite
    seed = @@seed || rand(1000..9999)
    srand seed
    puts "seed #{seed}\n"

    @@groups.shuffle.each do |c|
      c.run_group
    end

    print "\n#{GREEN}ok#{RESET}\n"
  end

  def self.run_group
    group = new

    tests = public_instance_methods(false)
      .grep(/^test_/)
      .shuffle

    if @@name
      tests = tests.select { |t| t.to_s == @@name }
      if tests == []
        return
      end
    end

    if tests == []
      return
    end

    puts "\n#{self}"
    tests.each { |test| group.run_test(test) }
  end

  def db
    DB.pool
  end

  def initialize
    @tx = true
    @stubs = []
  end

  def run_test(test)
    setup
    send(test)
    puts "  #{GREEN}#{test}#{RESET}"
  rescue => err
    puts "  #{RED}#{test}#{RESET}"
    lines = err.backtrace.reject { |l| l.include?(__FILE__) }.join("\n  ")
    puts "\n#{RED}fail: #{err}#{RESET}\n  #{lines}"
    exit 1
  ensure
    teardown
  end

  def ok(expression, m = nil)
    if !expression
      raise Test::Failure, m
    end
  end

  def stub(methods)
    obj = Object.new
    calls = Hash.new { |h, k| h[k] = [] }

    methods.each do |meth, return_value|
      obj.define_singleton_method(meth) do |*args, **kwargs, &block|
        calls[meth] << {args: args, kwargs: kwargs}
        if return_value.is_a?(Proc)
          return_value.call(*args, **kwargs, &block)
        else
          return_value
        end
      end
    end

    obj.define_singleton_method(:called?) do |meth|
      calls[meth] != []
    end

    obj.define_singleton_method(:calls) do
      calls
    end

    obj
  end

  def stub_class(klass, methods)
    methods.each do |meth, return_value|
      orig = klass.method(meth)
      @stubs << [klass, meth, orig]

      klass.define_singleton_method(meth) do |*args, **kwargs, &block|
        if return_value.is_a?(Proc)
          return_value.call(*args, **kwargs, &block)
        else
          return_value
        end
      end
    end
  end

  private def setup
    if @tx
      db.exec("BEGIN")
    end
  end

  private def teardown
    @stubs.reverse.each do |klass, meth, orig|
      klass.define_singleton_method(meth, orig)
    end
    @stubs = []

    if @tx
      db.exec("ROLLBACK")
    else
      tablenames = db.exec(<<~SQL).map { |row| row["tablename"] }
        SELECT
          tablename
        FROM
          pg_tables
        WHERE
          schemaname = 'public'
          AND tablename != 'users'
        ORDER BY
          tablename
      SQL

      tablenames.each do |t|
        db.exec("DELETE FROM #{t}")
      end

      db.exec("DELETE FROM users WHERE id != 1")
    end
  end
end

at_exit { Test.run_suite }
