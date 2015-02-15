#!/usr/bin/env ruby
#####################

require 'rubygems'
require 'gruff'
require 'pp'

require 'aadse_utilities'

require 'EngagementZone'

def gen_pk
  
  total = 265
  third = total / 3
  
  max_pk = rand(41)+60

  pk = Array.new
  total.times do |x|
    pk << max_pk + Math.sin(x)
  end

  x_start = rand(third)
  x_end   = rand(third)

  x_start.times do |x|
    pk[x] = 0
  end

  xx=total - x_end

  (xx..total).each do |x|
    pk[x]=0
  end

  return pk

end ## end of def gen_pk

#############################################
# Assumes a single lobe EZ for each launcher

which_threat = 'RMSRBM_1'

st = Time.now

eza = Array.new

5.times do |x|
  eza << EngagementZone.new("BLPac3_#{x+1}", which_threat, gen_pk)
end


r1a = Array.new
r2a = Array.new

eza.each do |ez|
  r1a << ez.range.first
  r2a << ez.range.last  
end

r1 = r1a.min
r2 = r2a.max

r  = (r1..r2)

puts "="*35
puts "Combined EZ range: #{r}"

zeros = Array.new

r.each { |x| zeros<<0 }

pka = Array.new

pka << zeros.dup


eza.each do |ez|
  pka << zeros.dup
  pka.last[ez.range] = ez.pk
end

et = Time.now

############################################################


st2=Time.now

g = Gruff::Line.new(1200)

g.theme_keynote()

g.title           = "#{which_threat}: Engagement Zones"
g.no_data_message = "Can Not Engage"
g.sort            = true
g.baseline_value  = 58
g.dot_radius      = 2
g.line_width      = 1
g.x_axis_label    = "Seconds"
g.y_axis_label    = "PK"

eza.length.times do |x|
  g.data(eza[x].launcher_name,  pka[x+1])
end


g.labels  = Hash.new
pka[0].length.times {|x| g.labels[x] = x.to_s if 0==x%15}

file_path = $AADSE_ROOT + "engmngr/stand_in/GUI/public" + "#{which_threat}_ez.png"
file_path_str = file_path.to_s

system "rm #{file_path_str}"
g.write(file_path_str)
system "open #{file_path_str}"

et2=Time.now


puts et  - st
puts et2 - st2
