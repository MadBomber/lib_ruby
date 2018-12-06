# lib/ruby/wrappable.rb
# See: https://blog.appsignal.com/2018/10/02/ruby-magic-class-level-instance-variables.html

module Wrappable
  def inherited_wrappers
    ancestors
      .grep(Wrappable)
      .reverse
      .flat_map(&:wrappers)
  end

  def new(*arguments, &block)
    instance = allocate
    inherited_wrappers.each { |mod|instance.singleton_class.include(mod) }
    instance.send(:initialize, *arguments, &block)
    instance
  end
end

__END__

module Logging
  def make_noise
    puts "Started making noise"
    super
    puts "Finished making noise"
  end
end

class Bird
  extend Wrappable

  wrap Logging

  def make_noise
    puts "Chirp, chirp!"
  end
end

module Powered
  def make_noise
    puts "Powering up"
    super
    puts "Shutting down"
  end
end

class Machine
  extend Wrappable

  wrap Powered

  def make_noise
    puts "Buzzzzzz"
  end
end

module Flying
  def make_noise
    super
    puts "Is flying away"
  end
end

class Pigeon < Bird
  wrap Flying

  def make_noise
    puts "Coo!"
  end
end

bird = Bird.new
bird.make_noise
# Started making noise
# Chirp, chirp!
# Finished making noise

machine = Machine.new
machine.make_noise
# Powering up
# Buzzzzz
# Shutting down

pigeon = Pigeon.new
pigeon.make_noise
# Started making noise
# Coo!
# Finished making noise
# Is flying away
