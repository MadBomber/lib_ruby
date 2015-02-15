#####################################################
###
##  File:  aadse_utilities.rb
##  Desc:  Some of these utilities methods may be if sufficient generic
##         nature to be included into the ISE/Portal/lib
#

# $debug_cmd = true   ## Print STK commands


###################
def dont_execute_me
  puts "\nFile: " + $0
  puts "\n\nThis file is not directly executable.  It is a library module"
  puts "that gets 'required' or 'loaded' by other programs."
  puts
  exit
end

dont_execute_me if __FILE__.include?($0)    ## Prevent this file from executing directly

##########################################################################
## Common libraries used by the AADSE Simulation

require 'rubygems'
require 'pathname_mods'   ## Modifications to the StdLib class Pathname
require 'pp'              ## StdLib: supports pretty printing of raw values like the inspect method
require 'xmlsimple'
#require 'gruff'           ## TODO: consider using ChartDriver in place of gruff

# ISE Common libraries
require 'debug_me'        ## Generic method for displaying variable names and values
require 'PortPublisher'   ## Output to IP:Port
require 'LlaCoordinate'   ## Utilitie methods for geo-location
require 'SimTime'         ## Manage the simulation time
require 'SimStatus'       ## Manage the simulation status

# AADSE Common Libraries
require 'guid'
require 'logger_junk'


###############################
## Hold over junk from 2009 sim
## FIXME: May no longer be required.

$NACK       = "NACK"
$ACK        = "ACK"
$ENDOFLINE  = "\n"

########################################################################
## Ensure that AADSE System-wide environment varables are set correctly
unless ENV['ISE_ROOT'] and ENV['AADSE_ROOT']
  msg  = "Correct the problem described below and try again"
  msg << "#{$ENDOFLINE}\tThe ISE setup_symbols file has not been sourced." unless ENV['ISE_ROOT']
  msg << "#{$ENDOFLINE}\tThe AADSE setup_symbols file has not been sourced." unless ENV['AADSE_ROOT']
  fatal_error msg
end

$ISE_ROOT           = Pathname.new(ENV['ISE_ROOT'])
$AADSE_ROOT         = Pathname.new(ENV['AADSE_ROOT'])

$AADSE_RAILS_ENV    = ENV['AADSE_RAILS_ENV']

$DATA_DIR = Pathname.new(ENV['DATA_DIR'])
$IDP_DIR  = Pathname.new(ENV['IDP_DIR'])
$SG_DIR   = Pathname.new(ENV['SG_DIR'])
$PK_DIR   = Pathname.new(ENV['PK_DIR'])
$TRAJ_DIR = Pathname.new(ENV['TRAJ_DIR'])

$WEB_APPS = Pathname.new(ENV['WEB_APPS'])
$MP_DIR   = Pathname.new(ENV['MP_DIR'])
# $EM_DIR   = Pathname.new(ENV['EM_DIR'])
$SC_DIR   = Pathname.new(ENV['SC_DIR'])



############################################################
## Establish some global data items

$sim_time = SimTime.new(  1.0,                        # time step of one second
                          '11 sep 2001 07:00:00.000', # start time
                          '11 sep 2001 07:15:00.000'  # end time
                       )


sim_time_config_filename    = $TRAJ_DIR + 'sim_time.xml'

if sim_time_config_filename.exist?
  xml_buffer = ""
#  sim_time_config_filename.each_line { |a_line| xml_buffer << a_line }
#  st = XmlSimple.xml_in(xml_buffer, { 'KeyAttr' => 'name' })["sim_time"]

  st = XmlSimple.xml_in(sim_time_config_filename.to_s, { 'KeyAttr' => 'name', 'ForceArray' => false })   # ["sim_time"]
  
  debug_me {[:xml_buffer,:st]}  if $debug

  $sim_time.duration = st['duration'].to_f
  $sim_time.end_time = $sim_time.start_time + $sim_time.duration
  
  debug_me {'$sim_time'}  if $debug
  
else
  puts "WARNING: file does not exist. #{sim_time_config_filename}"
end


debug_me('SIMTIME'){:$sim_time}  if $debug


$sim_status = SimStatus.new


################################################
## TODO: Create a Sim-wide next_unit_id service

$last_unit_id = 0

def get_next_unit_id
  $last_unit_id += 1
end




###############################################
## write a pid file to the same directory
## as the file that is requesting the pid file
## to be written.

def write_pid_file_for(dash_file)

  me          = Pathname.new(dash_file)
  me_basename = me.basename
  me_fullpath = me.realpath.dirname

  pid_filename = me_fullpath + "#{me_basename}.pid"

  pid = Process.pid

  pf = File.new(pid_filename.to_s,"w")
  pf.puts pid
  pf.close

end



##########################################################
## Utility functions that query the global $sim_status
def sim_running?
  $sim_status = SimStatus.new unless $sim_status
  return $sim_status.running?
end

def sim_paused?
  $sim_status = SimStatus.new unless $sim_status
  return $sim_status.paused?
end




#############################################
## These modes are only needed for ruby 1.8.6

module Kernel
  private
  def this_method_name
    caller[0] =~ /`([^']*)'/
    return $1
  end

  def calling_method_name level = 1
    caller[level] =~ /`([^']*)'/
    return $1
  end
end




#############################################################
##  Object label coding convention for STK, IDP, et.al. :
##
##    FCmmm_xxx
##
##    where:
##      F = Force (R,G,B,Y)
##      C = Class (A=aircraft, G=geography; L=launcher; M=missle; R=radar)
##      mmm = sub-class (no constraint on length of subclass because its terminated with the '_' character)
##      xxx = instance ID in the character set: AZaz09-
##
##  See http://138.209.52.103/twiki/bin/view/ISEwiki/EngagementManagerStandinModel

class String
  def is_red_force?
    self[0,1] == 'R' || self[0,1] == 'r'
  end
  #
  def is_blue_force?
    self[0,1] == 'B' || self[0,1] == 'b'
  end
  #
  def is_pending?
    self[0,1] == 'G' || self[0,1] == 'g' || self[0,1] == 'Y' || self[0,1] == 'y'
  end
  #
  def is_missile?
    self[1,1] == 'M' || self[1,1] == 'm'
  end
  #
  def is_aircraft?   # actually more like air breather, includes cruise missiles, heilos, uavs, etc.
    self[1,1] == 'A' || self[1,1] == 'a'
  end
  #
  def is_launcher?
    self[1,1] == 'L' || self[1,1] == 'l'
  end
  #
  def is_battery?
    self[0,11].downcase == 'upper_tier_' || self[0,11].downcase == 'lower_tier_'
  end
  #
  def is_red_missile?
    self.is_red_force? && self.is_missile?
  end
  #
  def is_red_aircraft?
    self.is_red_force? && self.is_aircraft?
  end
  #
  def is_cruise_missile?
    self.is_aircraft? && self[2,2].upcase == 'CM'
  end

end  ## end of mods to class String to support label naming convention





########################################################################
## making the + method the same as the merge method for all Hash objects

class Hash
  alias :+ :merge
end ## end of class Hash




##############################################################
## get a rought idea about how long a method takes to complete
def time_this(function, *args)
  start_time = Time.now

  method(function).call(*args)

  end_time = Time.now

  return end_time - start_time
end



##########################
def print_file(a_filename)

  file_name = a_filename.class.to_s == 'String' ? a_filename : a_filename.to_s

  begin
    file = File.new(file_name, "r")
    while (line = file.gets)        # The = is a real assignment NOT an equivalance test
      puts "#{line}"
    end
    file.close
  rescue => err
    puts "Exception: #{err}"
  end

end




############################################
## The methods below this line may be OBE ##
############################################
#####
 ###
  #



#####################
def add_endofline msg
  ## add an $ENDOFLINE if none is present at the end of the string.
  msg << $ENDOFLINE unless $ENDOFLINE == msg[0-$ENDOFLINE.length, $ENDOFLINE.length]
  return msg
end


###################
def count_lines msg
  msg = add_endofline msg #ensure it ends with $ENDOFLINE
  line_count = 0
  msg.gsub($ENDOFLINE) {|a| line_count += 1}
  return line_count
end



####################
def ack_this(msg='')

  return "#{$ACK}#{$ENDOFLINE}" if msg.empty?

  line_count = count_lines msg

  return "#{$ACK}#{$ENDOFLINE}#{line_count}#{$ENDOFLINE}#{msg}"

end


#####################
def nack_this(msg='', max_nack_lines = 1)
  if count_lines(msg) > max_nack_lines
    internal_error "NACK error message has more than #{max_nack_lines}: #{count_lines(msg)} lines."
  end

  return "#{$NACK} #{msg}"
end



#############################################################
def find_parameters(a_dir,lvl=0)
  die "Not a Pathname class instance" if 0==lvl and not 'Pathname'==a_dir.class.to_s 
  an_array = []
  a_dir.children.each do |c|
    if c.directory?
      an_array << find_parameters(c,lvl+1) unless c.to_s.downcase.include?("deactive")
    else
      an_array << c.realpath if c.basename.to_s == 'parameters'
    end
  end
  return (0==lvl ? an_array.flatten! : an_array)
end


###############################
def get_traj_rv(param_pathname)
  die "Not a Pathname class instance" unless 'Pathname'== param_pathname.class.to_s 
  param_pathname.parent.children.each do |c|
    unless c.directory?
      return c.realpath if c.basename.to_s == 'traj_rv.txt'
    end
  end

  return false

end




########################################################
## There is a designated directory structure and
## naming convention that allows the patching of
## the UIMDT short comings w/r/t force designation
## and the designation of aircraft over cruse missiles
##
## This method inspects the full pathname for a parameters file
## and extracts the force designation and the major weapon category
## using the naming convention.

def parameters_filename_mojo(pf)

  ################################################################################
  ## New way based on name field inside the parameters file from UIMDT/SG
    
  case pf.missile_name.downcase
    
    when 'srbm' then
      force_designation_  = :red
      weapon_category_    = :missile
    
    when 'mrbm' then
      force_designation_  = :red
      weapon_category_    = :missile
    
    when 'icbm' then
      force_designation_  = :red
      weapon_category_    = :missile
    
    when 'airliner' then
      force_designation_  = :blue
      weapon_category_    = :aircraft
    
    when 'cargoship' then
      force_designation_  = :blue
      weapon_category_    = :aircraft
    
    when 'cm' then
      force_designation_  = :red
      weapon_category_    = :aircraft
    
    when 'cruisemissile' then
      force_designation_  = :red
      weapon_category_    = :aircraft
    
    when 'helicopter' then
      force_designation_  = :red
      weapon_category_    = :aircraft
    
    when 'red_fighter' then
      force_designation_  = :red
      weapon_category_    = :aircraft
      
    else
      force_designation_  = :invalid
      weapon_category_    = :unknown
      
  end ## end of case pf.missile_name.downcase



  ###################################################################################
  ## Legacy process based upon a directory structure naming convention
  ## Determine force designation from path name

  if :invalid == force_designation_

    force_designation_ = :red      if pf.pathname_.fnmatch('/**/SG/**/[rR][aAmM]/*')
    force_designation_ = :blue     if pf.pathname_.fnmatch('/**/SG/**/[bB][aAmM]/*')
    force_designation_ = :pending  if pf.pathname_.fnmatch('/**/SG/**/[yYgG][aAmM]/*')

    force_designation_ = :red      if pf.pathname_.fnmatch('/**/SG/[rR][aAmM]/*')
    force_designation_ = :blue     if pf.pathname_.fnmatch('/**/SG/[bB][aAmM]/*')
    force_designation_ = :pending  if pf.pathname_.fnmatch('/**/SG/[yYgG][aAmM]/*')
    
    if :invalid == force_designation_
      force_designation_ = :red      if pf.pathname_.fnmatch('/**/[rR][eE][dD]')
      force_designation_ = :blue     if pf.pathname_.fnmatch('/**/[bB][lL][uU][eE]')
      force_designation_ = :pending  if pf.pathname_.fnmatch('/**/[yY][eE][lL][lL][oO][wW]')
      force_designation_ = :pending  if pf.pathname_.fnmatch('/**/[gG][rR][eE][eE][nN]')
      force_designation_ = :pending  if pf.pathname_.fnmatch('/**/[pP][eE][nN][dD][iI][nN][gG]')
      force_designation_ = :pending  if pf.pathname_.fnmatch('/**/[uU][nN][kK][nN][oO][wW][nN]')
    end
    
    case force_designation_
      when :red then
        match_regex = '[rR]'
      when :blue then
        match_regex = '[bB]'
      when :pending then
        match_regex = '[gGyY]'
      else
        raise "InvalidFileName: unable to determine force assignment."
    end
  
  end ## end of if :invalid == force_designation_
  
  ######################################################################################
  ## Determine weapon categroy from path name
  
  if :unknown == weapon_category_
  
    weapon_category_ = :missile  if pf.pathname_.fnmatch("/**/SG/**/#{match_regex}[mM]/*")
    weapon_category_ = :aircraft if pf.pathname_.fnmatch("/**/SG/**/#{match_regex}[aA]/*")
    weapon_category_ = :missile  if pf.pathname_.fnmatch("/**/SG/#{match_regex}[mM]/*")
    weapon_category_ = :aircraft if pf.pathname_.fnmatch("/**/SG/#{match_regex}[aA]/*")
    
    if :unknown == weapon_category_
      weapon_category_ = :aircraft if pf.pathname_.fnmatch("/**/CM/*")
      weapon_category_ = :missile  if pf.pathname_.fnmatch("/**/ICBM/*")
      weapon_category_ = :missile  if pf.pathname_.fnmatch("/**/LRBM/*")
      weapon_category_ = :missile  if pf.pathname_.fnmatch("/**/MRBM/*")
      weapon_category_ = :missile  if pf.pathname_.fnmatch("/**/SRBM/*")
    end
  
  end
  
  #################################################################################
  ## Wrap up
  
  raise "InvalidFileName: unable to determine weapon category." if weapon_category_ == :unknown
  
  pf.add('force_designation_',  force_designation_)
  pf.add('weapon_category_',    weapon_category_)
   
end ## end of def parameters_filename_mojo(pf)







=begin
#######################################
## TODO: Replace gruff with ChartDriver
def create_ez_graphs( toc,      ## a full TOC object
                      threat)   ## a full threat object -- either Aircraft or Missile

  st = Time.now   # FIXME: Use the new timer method
  
  $pc_time_limit = 900  # SharedMemCache.get('pc_time_limit') unless defined?($pc_time_limit)

  # time-window range for engagement zone
  
  r1 = $sim_time.offset
  r2 = r1 + 182           # A wundow about 3 minutes big
  r2 = $pc_time_limit if r2 > $pc_time_limit
  
  ez_time_window = (r1..r2)


  ############################
  # Graph the engagement zones
  # TODO: consider using ChartDriver in place of gruff
  
  g = Gruff::Line.new(1200)

  g.theme_keynote()

  g.title           = "#{threat.name}: Engagement Zones"
  g.no_data_message = "Not Engageble"
  g.sort            = true
  g.baseline_value  = 58
  g.dot_radius      = 2
  g.line_width      = 1
  g.x_axis_label    = "Relative Seconds from Now"
  g.y_axis_label    = "PK"


  ###########################################################
  # Build an engagement zone array from all engagement zones
  
  eza = Array.new
  
  toc.launchers.each_key do |name|
    shooter = SharedMemCache.get name
    toc.launchers[name] = shooter          
    eza << shooter.ez[threat.name] if shooter.ez[threat.name]
  end
  
  if eza.empty?
    log_this "No engagement zones for #{threat.name} exist; so, no graph"
    return
  end
  
  
  ############################################
  # build a Pk Array from all engagement zones
  
  zeros = Array.new

  $pc_time_limit.times do
    zeros << 0
  end

  pka = Array.new

  eza.each do |ez|
    pka << zeros.dup
    pka.last[ez.range] = ez.pk
  end



  #############################################
  # Load the Pk data for each EZ into the graph
  
  eza.length.times do |x|
    g.data(eza[x].launcher_name,  pka[x][ez_time_window])
  end

  #########################################
  # Set the tick mark labels for the X-axis
  
  g.labels  = Hash.new
  pka[0].length.times {|x| g.labels[x] = x.to_s if 0==x%15}
  
  ###################################
  # Draw the graphic to an image file
  
  image_path      = $AADSE_ROOT + "engmngr/stand_in/GUI/public" + "#{threat.name}_ez.png"
  image_path_str  = image_path.to_s
  
  g.write(image_path_str)
  
  et = Time.now ## FIXME: Use the new timer method
  
  puts ">>>>>>> EZ IMAGE BUILD TIME: #{et - st}  #{toc.name} against #{threat.name} at sto: #{$sim_time.offset}"

end ## end of def create_ez_graphs

=end



