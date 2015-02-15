#######################################################
###
##  File:  EngagementZone.rb
##  Desc:  Encapsulates stuff for engagement zones
#
# Assumes a single lobe EZ

class EngagementZone

  attr_accessor :range          # QUESTION: The EZ intercept time ?? range
  attr_accessor :mid_point      # The middle of the EZ
  attr_accessor :pk             # The Pk array for the EZ range
  attr_accessor :launcher_name  # Name of the launcher
  attr_accessor :target_name    # Name of the target

  def initialize(l_name, t_name, pk_slice)
  
  
    debug_me {[:l_name, :t_name, "pk_slice.length", "pk_slice.last"]}  if $debug
  
  
    @launcher_name  = l_name
    @target_name    = t_name
  
    @pk_slice = pk_slice

    pk_length = pk_slice.length - 1
    r1=0
    r2=0

    found_first_nonzero_pk = false

    (0..pk_length).each do |index|

      pk = pk_slice[index]

      unless 0 == pk
        unless found_first_nonzero_pk
          r1 = index

          found_first_nonzero_pk = true
        end

        r2 = index
      end

    end
 
    @mid_point  = r1 + (r2 - r1) / 2
    @range      = (r1..r2)
    @pk         = pk_slice[@range]

    @range      = nil unless found_first_nonzero_pk
    
  end  ## end of initialize

  def update_pk
    @pk = @pk_slice[@range]
  end
  
  #######
  def max
    mpk = @pk.max
#    eit = @pk.index(mpk) + @range.first
    eit = 0 # Don't think this is ever used, was throwing errors occasionally
    return [mpk, eit]
  end
  
  ########
  def to_s
    a_str = ""
    a_str << "Launcher: #{@launcher_name}  Target: #{@target_name}\n"
    a_str << "EZ Range: #{@range} MidPoint: #{@mid_point}\n"
    a_str << "Max. Pk:  #{@pk.max}\n"
    a_str << "PkTable:  #{@pk.join(', ')}\n"
    return a_str
  end
  
end ## end of class EngagementZone
