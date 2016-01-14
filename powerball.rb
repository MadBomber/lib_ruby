require 'pathname'

class Powerball
  class << self
    def format(*args)
      a_pick = (1 == args.size) ? args[0] : args
      raise 'Invalid ticket; requires 6 integers.' unless 6 == a_pick.size
      a_pick[0..4].sort.join(', ') + ' - ' + a_pick[5].to_s
    end

    def odds
      # n!/k!(n-k)! -- combination n things taken k at a time

      wbm = 69 # white ball max
      wbc = 5  # white ball count
      rbm = 26 # red ball max

      nf = (1..wbm).inject(:*)
      kf = (1..wbc).inject(:*)
      j = wbm - wbc
      jf = (1..j).inject(:*)
      jkf = kf*jf
      odds = (nf / jkf) * rbm
      odds_humanized = odds.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
      "1 in #{odds_humanized}"
    end
  end # class << self


  def initialize(winners_file=nil)
    # @pick is an array pf 6 integers; the first five are asending order
    @pick     = [0,0,0,0,0,0]

    # The @winners hash uses a pick array as the key.  The value is a date string
    @winners  = Hash.new

    # The winners_file is used to build the winners hash.  The hash is
    # used in the method pick_a_winner
    ingest_winners_file(winners_file)
  end

  # pick some numbers
  def pick
    @pick = (1..69).to_a.sample(5).sort + (1..26).to_a.sample(1)
    to_s
  end

  # convert the last pick into a string
  def to_s
    self.class.format @pick
  end

  # is the last pick a previous winner?
  def winner?
    not @winners[@pick].nil?
  end

  # The winners file is obtained from the powerball website
  # via external download.  The file is a text file.  The
  # first line is a header: 
  #     Draw Date   WB1 WB2 WB3 WB4 WB5 PB  PP
  def ingest_winners_file(filename)
    return(false) if filename.nil?
    a_path = Pathname.new filename
    raise "Unknown file: #{filename}" unless a_path.exist?
    line_cnt = 0
    a_path.readlines.each do |a_winner|
      line_cnt += 1
      next if skip(a_winner)
      insert_into_winners_hash(a_winner)
    end
    true
  end

  # determine wither a line should be skipped
  def skip(a_line)
    @line_cnt ||= 0
    @line_cnt += 1
    1 == line_cnt || 
    a_line.empty? || 
    a_line.strip.start_with?('#')
  end

  # add a previous winning pick to the winners hash
  def insert_into_winners_hash(a_winner)
    an_array = a_winner.split
    a_date   = an_array.shift
    an_array.map!{|e| e.to_i}
    @winners[ an_array[0..4].sort + [an_array[5]] ] = a_date
  end

  # Make as many picks as necessary to get a pick which
  # was a previous winning combintation.  The purpose of
  # this function is to see how many picks it takes before
  # coming up with a previous winnder.
  def pick_a_winner
    if @winners.empty?
      puts "Save your money.  There are no winners."
      return false
    end
    pick_cnt = 0
    until winner?
      pick_cnt += 1
      pick
    end
    puts "We have a winner!  #{to_s} after #{pick_cnt} picks."
    puts "   Date of winning drawing: #{@winners[@pick]}"
    true
  end

end # class Powerball

