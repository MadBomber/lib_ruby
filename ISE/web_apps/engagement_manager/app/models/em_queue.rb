
# FIXME: Do not embedded the threat object in the queue; rather, just keep track of the
#        threat_label for use as a key into the global data store.


# NOTE: Although this class is refered to as a queue, it has no queue-like
#       qualities.  Its just a collection.

class EmQueue
  
  # the queue_name in $valid_queue_names
  attr_accessor :label
  
    
  # An Array of EmQueue::Entries
  # Array is used to support sorting of the data for presentation
  # Could have used a sortable hash
  attr_accessor :entries                

  
  # The title to be displayed on the web page above the queue elements
  attr_accessor :display_title
  

  ########################################################
  ## An object in the EntryArray
  class Entry
    attr_accessor :label
    attr_accessor :priority
    
    def initialize(label, priority=0.0)
      @label      = label
      @priority   = priority
    end
    
  end ## end of class EmQueueEntry


  ########################################################
  ## An array of Entries
  class EntryArray < Array
  
    ##############
    def initialize
      super
    end
    
    ##########################################
    ## Does the array include this entry label
    def include?(a_label)
      return false if self.empty?
      self.each_index do |inx|
        return true if self[inx].label == a_label
      end
      return false
    end
    
    ################################################
    ## Remove this entry from the array if its there
    def remove!(a_label)
      if include?(a_label)
        inx = self.index(a_label)
        self[inx] = nil
        self.compact!
      end
    end
    
    ################################################
    ## return the index of the label in the array
    def index(a_label)
      return nil unless include?(a_label)
      found_at = -1
      self.each_index do |inx|
        found_at = inx
        break if self[inx].label == a_label
      end
      return found_at
    end
    
    ################################################
    ## Only insert entries into the array
    def <<(an_entry)
      unless 'EmQueue::Entry' == an_entry.class.to_s
        debug_me(:tag=>"EXPECTED EmQueue::Entry", :trace=>true){:an_entry}
        raise "That was not of type EmQueue::Entry"
      end
      super
    end
    
    ################################################
    ## Sort the entries by the priority and the last
    ## 3 characters of their label
    def sort
      return self.sort_by { |i| [i.priority, i.label.last(3)] }.reverse
    end
    
  end ## end of class EntryArray < Array



  #########################################################
  # Constructor, creates a new EmQueue instance with the given label
  # The instance is by convention placed in the global data store:
  # $em_queues (a hash) with the hash key the same as the label.
  # This is done in the config/initializers/em_global.rb file
  def initialize(a_label)
  
    @label          = a_label
    @display_title  = a_label.to_s.titleize
    @entries        = EntryArray.new    # an array of EmQueue::Entry
    
  end ## def initialize(a_label, a_type)
  




  
  ###################################
  # Remove all entries from the queue
  # Done on receipt of the start_frame message were the
  # frame count is 1
  def reset
    puts "Resetting #{@label} ..."
    @entries.clear
  end ## def reset
  
#  alias_method :clear, :reset     # SMELL: does anyone call clear on an EmQueue ?? if not, delete this alias



  ###########
  def active?
    return($valid_active_queue_names.include?(label))
  end ## def active?
  
  
  #############
  def inactive?
    return(not $valid_active_queue_names.include?(label))
  end ## def inactive?
  

  ########################################################
  ## Sort the queue
  def sort
    return @entries.sort if active?
    return @entries
  end
  
    
  ########################################################
  ## SMELL: Why are we using an object and not a label?
  def update_threat(threat_label)
  
    unless "String" == threat_label.class.to_s
      debug_me(:tag=>"EXPECTED STRING", :trace=>true){["@label", :threat_label]}
      return false
    end
    
    
#    debug_me {:threat_label}
    

    if $em_threats[threat_label].status == @label
    
      if @entries.include?(threat_label)
#        debug_me("UPDATING") {:threat_label}
        inx                     = @entries.index(threat_label)
        @entries[inx].priority  = $em_threats[threat_label].priority
      else
#        debug_me("INSERTING") {:threat_label}
        @entries << Entry.new(threat_label, $em_threats[threat_label].priority)
      end
      
    else
#      debug_me("REMOVING") {:threat_label}
      @entries.remove!(threat_label)
    end
    
    return true
    
  end ## def update_threat(a_threat)
  


  ##########################################################
  ## insert an entry into the queue for this threat_label
  def <<(threat_label)
    return @entries if @entries.include? threat_label
    @entries << Entry.new(threat_label, $em_threats[threat_label].priority)
  end

  
    

end ## class EmQueuesController < ApplicationController
