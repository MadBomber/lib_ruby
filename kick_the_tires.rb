# encoding: utf-8
#########################################################
###
##  File: kick_the_tires.rb
##  Desc: Poke around; check things out; see if you want it
##  By:   Dewayne VanHoozer (dvanhoozer@gmail.com)

require 'awesome_print'
require 'pathname'
require 'pry'

module KickTheTires

  if caller.empty?
    required_by_filename = __FILE__
  else
    required_by_filename = caller.last.split(':').first
  end

  SOURCE = Pathname.new(required_by_filename).readlines.map{|a_line| a_line.chomp.strip}

  def show_source
    puts
    puts "-"*75
    a_string    = caller.last
    source_line = a_string.split(' ').first.split(':')[1].to_i
    puts "Source #=> #{SOURCE[source_line-1]}" # MAGIC: zero-based index
  end

  def show(a_thing)
    show_source
    puts "Showing #{a_thing.class} #=>"
    ap a_thing, {indent: 2, raw: true}
  end

  def assert(its_true)
    unless its_true
      show_source
      print 'Result #=> '
      puts "Expected TRUE got FALSE"
    end
  end

  def refute(its_really_true)
    if its_really_true
      show_source
      print 'Result #=> '
      puts 'Expected FALSE got TRUE'
    end
  end

  def assert_equal(expected_this, got_that)
    unless expected_this.to_s == got_that.to_s
      show_source
      puts 'Result #=>'
      puts "Expected This: #{expected_this}"
      puts "But Got That:  #{got_that}"
      puts
    end
  end

  # TODO: Need a little more thinking about this
  def hands_on
    show_source
    puts "Entering pry.  Type 'help' for available commands."
    puts "Enter the command 'up' to kick the tires on the new ride."
    binding.pry
  end

end # module KickTheTires
