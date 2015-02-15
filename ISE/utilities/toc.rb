######################################################
###
##  File:  Toc.rb
##  Desc:  Generic TOC Class
#

require 'tewa'
require 'Launcher'
require 'ostruct'

class Toc
  
  attr_accessor :label
  attr_accessor :lla
  attr_accessor :defended_area_label
  attr_accessor :launchers
  attr_accessor :bids
  
  include Observable
  
  #############################################
  def initialize(label, defended_area_label=nil, lla=nil )
    @label                = label
    @lla                  = lla
    @defended_area_label  = defended_area_label
    @launchers            = Hash.new
    @bids                 = Hash.new
  end
  
  #############################
  def attach_launcher(launcher)
    unless @launchers.include?(launcher.label)
      @launchers[launcher.label]           = launcher
      @launchers[launcher.label].toc_label  = @label
      log_event "#{launcher.label} has been attached to TOC: #{@label}"
    end
  end
  
  #######################
  def can_engage?(target)
    answer = false
    
    threat_label = target.label
    
    @bids[threat_label] = Hash.new unless @bids.include?(threat_label)
    
    @launchers.each_pair do |launcher_label, shooter|
    
      @launchers[launcher_label] = shooter
      log_this "... asking #{launcher_label} if it can engage."
      my_answer = @launchers[launcher_label].can_engage?(target)
            
#      pp @launchers[label] if my_answer
      
      answer    = my_answer || answer
    end
    return answer
  end
  
  ###########################################################
  ## This method is specific to the AADSE Simulation
  ##
  ## SATRN Launcher Bid Calculation
  ##
  ## The factor weights (e.g. Pk_weight) are the same parameters retrieved
  ## from the Mission Planning GUI/TEWA Configuration as for the previous 
  ## launcher bid implementation.  If launcher inventory = 0, then the launcher
  ## does not have engageability, and its bid doesn’t have to be calculated.
  ##
  ## Launcher bid = (Pk_factor*Pk_weight) 
  ##              + (Inventory_factor*Inventory_weight) 
  ##              + (Cost_factor*Cost_weight) 
  ##              + (Time_factor*Time_weight) 
  #

  def select_launcher(bids, threat_label, threat_priority=0.0)

    # bids is an array of arrays.  An entry looks like this:
    #   [[pk, eit], launcher_label]
    
    return nil if bids.empty?
        
    highest_bid_factor      = 0.0
    selected_launcher_label  = nil    
    
    bids.each do |bid|
    
      pk              = bid[0][0]     # expressed as a percentage
      eit             = bid[0][1]     # earlist intercept time (in seconds)
      launcher_label  = bid[1]
      launcher_obj    = @launchers[launcher_label]

      bid_factor      = 0.0

      #############################################################
      # Factor: interceptor_pk
      # 
      # pk_factor = exp(0.7* (pk/100) ) -1
      # 
      # Pk = probability of kill from Pk lookup tables or entered as a % by the user into the mission planning GUI
      # Pk should be entered as a % into the equation.  
      # Pk_weight is entered by user in the mission planning GUI as a number from 0 to 100. 

      adjusted_pk   = Math.exp( 0.7 * ( pk.to_f / 100.0 ) ) - 1.0
      factor_value  = adjusted_pk * Tewa::CONFIG['weapon_assignment']['interceptor_pk']

      
      bid_factor   += factor_value
      
debug_me("TEWA Factor: interceptor_pk"){[:pk, :adjusted_pk, "Tewa::CONFIG['weapon_assignment']['interceptor_pk']",
  :factor_value, :bid_factor]}  if $debug
      
      #############################################################
      # Factor: time_until_ftl
      # 
      # Time_factor = exp(-0.2* TFTL ), TFTL >= 0.0
      # Time_factor = 2.0, TFTL < 0.0
      # TFTL = time of the first opportunity to launch – current time (i.e. available time in minutes until the first opportunity to launch)
      # If the first opportunity to launch has already passed (i.e.  TFTL < 0.0), then the Time_factor is 2.0
      # Time_weight is entered by the user in the mission planning GUI as a number from 0 to 100.		
      # time_to_launch is minutes
      
      time_to_launch      = (launcher_obj.time_data[threat_label].first_launch_time - $sim_time.now) / 60.0
      
      if time_to_launch >= 0.0
        # always true, expressed this way becuase customer said so
        time_factor = Math.exp( -0.2 * time_to_launch )
      else
        time_factor = 2.0
      end
      
      factor_value  = time_factor * Tewa::CONFIG['weapon_assignment']['time_until_ftl']
      
      bid_factor   += factor_value
      
debug_me("TEWA Factor: time_until_ftl"){[:time_to_launch, :time_factor, 
  "Tewa::CONFIG['weapon_assignment']['time_until_ftl']",
  :factor_value, :bid_factor]}  if $debug

      #############################################################
      # Factor: rounds_available
      # 
      # Inventory_factor = 1 - exp(-4.0 * (rounds_available/starting inventory) )
      # Rounds_available = number of rounds left for the launcher that is bidding
      # Starting_inventory = initial number of rounds at the start of the sim for the launcher that is bidding
      # Inventory_weight is entered by the user in the mission planning GUI as a number from 0 to 100.

      starting_inventory  = launcher_obj.rounds_available + launcher_obj.rounds_expended
      
      inventory_factor    = 1.0 - Math.exp( -4.0 * ( launcher_obj.rounds_available.to_f / starting_inventory.to_f ) )
      factor_value        = inventory_factor * Tewa::CONFIG['weapon_assignment']['rounds_available']
      
      bid_factor         += factor_value
      
debug_me("TEWA Factor: rounds_available"){["launcher_obj.rounds_available", "launcher_obj.rounds_expended", :starting_inventory,
  "Tewa::CONFIG['weapon_assignment']['rounds_available']",
  :inventory_factor, :factor_value, :bid_factor]}  if $debug

      #############################################################
      # Factor: interceptor_cost
      # 
      # Cost_factor = exp(-4.0 * (cost/100) )
      # cost = number from 0 to 100 entered by user into mission planning GUI
      # cost is the cost of a launcher type, relative to other launcher types in the scenario, where total cost of all launcher types = 100.  
      # E.g. if THAAD and PAC are the only launcher types in the scenario, and THAAD’s dollar value is 4 times that of PAC-3, then the THAAD cost = 80, and PAC-3 cost = 20.
      # Cost_weight is entered by the user in the mission planning GUI as a number from 0 to 100.
   
      adjusted_cost = Math.exp( -4.0 * ( launcher_obj.cost_factor / 100.0 ) )
      factor_value  = adjusted_cost * Tewa::CONFIG['weapon_assignment']['interceptor_cost']
      
      bid_factor   += factor_value
      
debug_me("TEWA Factor: interceptor_cost"){["launcher_obj.cost_factor", :adjusted_cost,
  "Tewa::CONFIG['weapon_assignment']['interceptor_cost']",
  :factor_value, :bid_factor]}  if $debug

      log_this "#{launcher_label} final bid_factor is #{bid_factor}"
      
      
      if bid_factor > highest_bid_factor
        highest_bid_factor      = bid_factor
        selected_launcher_label = launcher_label
      else
        log_this "highest bid factor so far is still #{highest_bid_factor} from #{selected_launcher_label}"
      end


      if bid_factor > 0.0
        @bids[threat_label][launcher_label]             = launcher_obj.time_data[threat_label]
        @bids[threat_label][launcher_label].bid_factor  = bid_factor
      end




    
    end ## end of bids.each do |bid|
    
    if selected_launcher_label
      log_this "#{selected_launcher_label} was selected because its bid_factor of #{highest_bid_factor} was the highest."
    else
      log_this "No launcher was selected"
    end


    return selected_launcher_label
    
  end ## end of def select_launcher(bids, threat_label, threat_priority=0.0)
    
    
  ##################################
  def auto_engage(target, 
                  weapons_hot=true)   ## represents command authorty to launch against the target
  
    log_this "Air Operations Center has#{weapons_hot ? '' : ' NOT'} released #{@label} to outo-engage #{target.label}"

    bids     = Array.new    # an array of arrays [ez.max, launcher_label
    
    @launchers.each_key do |label|
      ez = @launchers[label].bid_on(target)
      unless ez.nil?
        bids << [ez.max, label]
      end
    end
    
    if bids.empty?
      log_this "#{@label} has no bidders for #{target.label}"
      return nil     
    end
    
    log_this "#{@label} has the following bids for #{target.label}"
    
    highest_pk        = 0
    quickest_eit      = 999   # earliest intercept time (eit)
    selected_launcher = nil
    
    bids.each do |bid|
      log_this "   #{bid[1]} bids #{bid[0][0]} in #{bid[0][1] - $sim_time.offset} seconds"
      if bid[0][0].nil?
        # ignore bid
      elsif bid[0][0] > highest_pk
        highest_pk        = bid[0][0]
        quickest_eit      = bid[0][1]
        selected_launcher = bid[1]
      else
        if bid[0][0] == highest_pk
          if bid[0][1] < quickest_eit
            highest_pk        = bid[0][0]
            quickest_eit      = bid[0][1]
            selected_launcher = bid[1]
          end
        end
      end ## end of if bid[0][0] > highest_pk
    end ## end of bids.each do |bid|
    
    log_this "#{selected_launcher} has the highest Pk and quickest intercept time."
    
    # pk, eit only selection
    # answer = @launchers[selected_launcher].launch(target)
    
    selected_launcher = select_launcher(bids, target.label, target.threat_priority)

    if selected_launcher
      array_of_interceptor_labels = @launchers[selected_launcher].engage(target) if weapons_hot            
      return  [selected_launcher, array_of_interceptor_labels] ## could be empty array
    end
    
    debug_me("No Launchers were selected")
    return nil
    
    
  end ## end of def auto_engage(target)

end  ## end of class Toc
