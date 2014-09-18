module MadBomber
  module Kernel

    # When if and unless seem too black and white, use maybe
    #
    # Usage:
    #
    #   maybe(some_condition, 50) do
    #     puts "When some_condition is true, 50% of the time print this message"
    #   end

    def maybe(condition, rate=50, &block)
      rate = (rate < 1) ? (rate * 100).to_i : rate.to_i
      if condition  and  ( rand(100) < rate )
        yield
      end
    end

    # when condition is computationally expensive, use maybe2

    def maybe2(condition, rate=50, &block)
      rate = (rate < 1) ? (rate * 100).to_i : rate.to_i
      if ( rand(100) < rate )  and  condition
        yield
      end
    end 

  end # of module Kernel
end # of module MadBomber

__END__

extend MadBomber::Kernel

10.times do |x|
  maybe(true) do
    puts x
  end
end

10.times do |x|
  maybe(true, 0.5) do
    puts x
  end
end

# half the time condition is true
# half the time when its true increment hits
# resulting in hits about 25% of the time
def try_this
  hits = 0
  100.times do
    maybe(rand(100)<50) {hits += 1}
  end
  puts "Hits: #{hits}"
end

10.times {try_this}
