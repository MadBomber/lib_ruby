require 'pathname'

# TODO:   Normalize the @winners hash key

class Powerball
  def initialize(winners_file=nil)
    @winners = Hash.new
    ingest_winners_file(winners_file)
    @pick = [0,0,0,0,0,0]
  end

  def pick
    @pick = (1..69).to_a.sample(5).sort + (1..26).to_a.sample(1)
    to_s
  end

  def to_s
    format_as_string @pick
  end

  def winner?
    not @winners[@pick].nil?
  end

  def ingest_winners_file(filename)
    return if filename.nil?
    a_path = Pathname.new filename
    raise "Unknown file: #{filename}" unless a_path.exist?
    line_cnt = 0
    a_path.readlines.each do |a_winner|
      line_cnt += 1
      next if 1 == line_cnt || a_winner.empty? || a_winner.strip.start_with?('#')
      an_array = a_winner.split
      a_date   = an_array.shift
      an_array.map!{|e| e.to_i}
      @winners[ an_array[0..4].sort + an_array[5] ] = a_date
    end
  end

  def pick_until_you_win
    pick_cnt = 0
    until winner?
      pick_cnt += 1
      pick
    end
    puts "We have a winner!  #{to_s} after #{pick_cnt} picks."
    puts "   Date of winning drawing: #{@winners[to_s]}"
  end


  #class << self
    def format_as_string(a_pick)
      a_pick[0..4].sort.join(', ') + ' - ' + a_pick[5].to_s
    end
  #end

end # class Powerball

