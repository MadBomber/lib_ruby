#!/usr/bin/env ruby
#######################################################################
###
##  File:  emsi_gui.rb
##  Desc:  A notional GUI for parts of the Engagement Manager Stand-in
#

$debug  = false

##########################################
## The Gems/Libraries Used by this program

require 'aadse_utilities'

write_pid_file_for __FILE__

#require 'SharedMemCache'
require 'PortPublisher'
#require 'SimStatus'

require 'DefendedArea'
require 'Launcher'
require 'Target'
require 'Aircraft'
require 'Interceptor'


require 'gruff'
require 'sinatra'
require 'json'
require 'haml'
require 'pp'

######################################
## Site-wide parameters and globals ##
######################################


############################################
## Globals

$auto_refresh     = false
$refresh_interval = 5       ## in seconds




#################################################
## Establish a Connection to the Memory Cache

SharedMemCache.new    ## Use default IP:Port



##################################################
## Establish a Command Channel to the loop_closer

$em2sim = PortPublisher.new('138.209.52.147', 50003)  if '138' == ENV['IPADDRESS'][0,3]
$em2sim = PortPublisher.new('10.9.8.1', 50003)        if '10.' == ENV['IPADDRESS'][0,3]



##############################################################
## Statistics being collected are:
## SMELL: This hash needs to coordinated with the loop_closer

$stats = {
  :total_missiles               => [0, "Total Red Missiles"],
  :total_aircraft               => [0, "Total Red Aircraft"],
  :total_threats                => [0, "Total Known Red Force Threats"],
  :total_launchers              => [0, "Total Blue Force Launchers"],
  :total_rounds_expended        => [0, "Total Blue Force Interceptors Launched"],
  :total_attempted_engagements  => [0, "Total Attempts to Engage a Target"],
  :total_successful_engagements => [0, "Total Engagements Which Resulted in the Launch of an Interceptor"],
  :missile_engagements          => [0, "Total Inteceptor To Red Missile Pairings"],
  :aircraft_engagements         => [0, "Total Inteceptor To Red Aircraft Pairings"],
  :missile_kills                => [0, "Total Red Missiles Killed"],
  :aircraft_kills               => [0, "Total Red Aircraft Killed"],
  :missile_misses               => [0, "Total Shots at Red Missiles That Missed"],
  :aircraft_misses              => [0, "Total Shots at Red Aircraft That Missed"],
  :missile_leaks                => [0, "Total Red Missiles That Could Not Be Engaged"],
  :aircraft_leaks               => [0, "Total Red Aircraft That Could Not Be Engaged"],
  :active_missile_threats       => [0, "Current Active Missile Threats"],
  :active_aircraft_threats      => [0, "Current Active Aircraft Threats"]
}

# Attempt to coordinate sith loop_closer
stat_keys     = SharedMemCache.get('stat_keys')
add_these_keys= []
unless stat_keys.nil?
  stat_keys.each do |key|
    unless $stats.include?(key.to_sym)
      $stats[key.to_sym] = [0, "Undefined"]
      add_these_keys << key
    end
  end
end

unless add_these_keys.empty?
  $stderr.puts ""
  $stderr.puts "WARNING: Stats Hash is not in sync with the loop_closer"
  $stderr.puts "\r\tAdd these keys: \n\t\t#{add_these_keys.join("\n\t\t")}"
end




$flash = ""

$navigation_links = []    ## used in the sidebar





###########################################################
## Session definitions

enable :sessions

use Rack::Session::Cookie, :key => 'rack.session',
                           :domain => 'lmmfc-vrsil.com',
                           :path => '/',
                           :expire_after => 2592000, # In seconds
                           :secret => 'ISE-is-nice'





##############################################
## Set site username/password

use Rack::Auth::Basic do |username, password|
  [username, password] == ['vrsil', 'vrsil']
end








########################################################
## Define helper methods for use in views

helpers do

  include Rack::Utils
  alias_method :h, :escape_html

  ##############
  def protected!
    response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth") and \
    throw(:halt, [401, "Not authorized\n"]) and \
    return unless authorized?
  end


  ###############
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
  end


  ############
  def em(text)
    "<em>#{text}</em>"
  end


  ########################
  def render_flash_message
    $flash
  end


  #####################
  def render_navigation
    a_str = ""
    $navigation_links.each do |nl|
      a_str += "%li\n"
      tooltip = nl.length > 2 ? ", :title => \"#{nl[2]}\"" : ""
      a_str += "  %a{ :href => \"#{nl[1]}\"#{tooltip} }  #{nl[0]}\n"
    end
    haml a_str, :layout => false      ## IMPORTANT! :layout must be false else recursion happens
  end
  
  
  ################
  def auto_refresh
    "<meta http-equiv=\"refresh\" content=\"#{$refresh_interval}\" >" if $auto_refresh
  end
  
  
  ######################
  def render_stats_table
    a_str = ""
    $stats.each_pair do |key, value|
      a_str += "%tr\n"
      a_str += "  %td #{key}\n"
      a_str += "  %td #{value[0]}\n"
      a_str += "  %td #{value[1]}\n"
    end
    haml a_str, :layout => false
  end
  
  ###############################
  def render_active_threats_table
    a_str = ""
    $active_threats = SharedMemCache.get('active_threats')
    return haml("%p No active threats are known at this time.", :layout => false) if $active_threats.nil?
    
    a_str = "%table\n"
    a_str << "  %tr\n"
    a_str << "    %td\n"
    a_str << "      Track ID\n"
    a_str << "      %br STK Label\n"
    a_str << "    %td Time To Impact (seconds)\n"            
    a_str << "    %td\n"
    a_str << "      Target Area\n"
    a_str << "      %br Lat/Long\n"
#    a_str << "    %td xAltitude\n"
    a_str << "    %td Time To Intercept (seconds)\n"                
    a_str << "    %td iLatitude\n"
    a_str << "    %td iLongitude\n"
    a_str << "    %td iAltitude\n"
    a_str << "    %td Engaged By\n"
    $active_threats.each do |at|
      a_str << "  %tr\n"
      a_str << "    %td\n"
      a_str << "      %a{ :href => \"/threat/#{at[0]}\", :title => \"Click for details\"} #{at[0]}\n"
      a_str << "      %br #{at[1]}\n"           ## STK/Label
#      a_str << "    %td #{at[2][0]}\n"        ## Current LLA
#      a_str << "    %td #{at[2][1]}\n"
#      a_str << "    %td #{at[2][2]}\n"
      a_str << "    %td #{at[5]}\n"           ## Time to Impact
      a_str << "    %td\n"
      a_str << "      #{at[4][0]}\n"        ## Impact LLA
      a_str << "      %br #{at[4][1]}\n"
#      a_str << "    %td #{at[4][2]}\n"
      a_str << "    %td #{at[3][0]}\n"        ## Time to Intercept
      a_str << "    %td #{at[3][1][0]}\n"     ## Intercept LLA
      a_str << "    %td #{at[3][1][1]}\n"
      a_str << "    %td #{at[3][1][2]}\n"
      a_str << "    %td\n"                ## Engaged By
      a_str << "      %a{ :href => \"/launchers\", :title => \"Click for details\"} TBD Launcher\n"

    end
    haml a_str, :layout => false
  end

end # end of helpers do


##########
before do
  # .. this code will run before each HTTP event ..
  $sim_status   = SharedMemCache.get('sim_status')
end


#########################################################
## Configuration

configure :production do

  set :dbname, 'productiondb'

  not_found do
    "We're so sorry, but we don't what this is"
  end

  error do
    "Something really nasty happened.  We're on it!"
  end
end

configure :development do
  set :dbname, 'devdb'
end


###########################################################
## Global methods

def flash(msg)
  session[:flash] = msg
  $flash = msg
end








#########################################################
## SASS stylesheet

get '/stylesheets/button.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :button
end

get '/stylesheets/layout.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  sass :layout
end


############################################################
## Error Messages

not_found do
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "This Capability Is Not Available"

  haml :tbd
end

error do
  'Sorry there was a nasty error - ' + request.env['sinatra.error'].name
end




############################################################
## AADSE Engagement Manager (Stand-In) GUI Route Handlers ##
############################################################



############
## Dashboard

get '/' do
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "Dashboard"

  $navigation_links  = [["Launchers",   "/launchers"], 
                        ["Threats",     "/threats"],
                        ["Statistics",  "/statistics"] ]

  
  @ise_run_summary = SharedMemCache.get 'ISE:run_summary'

  haml :dashboard

end


#####################
## Simulation Control

get '/simcontrol/?' do
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "ISE Simulation Control"
  
  refresh_label = $auto_refresh ? ">Stop-Refresh" : ">Auto-Refresh"

  $navigation_links  = []

  if $sim_status.running?  
    $navigation_links  << [">Stop",         "/simcontrol/stop?t=#{Time.now.hash}", "Stop the Sim"]   ## like 'pause'
  else
    $navigation_links  << [">Start",        "/simcontrol/start?t=#{Time.now.hash}","Start the Sim"]  ## like 'gp'
  end

#  $navigation_links  << [">Reset",        "/simcontrol/reset",        "Reset the Sim to Initial Conditions"]      ## Does a complete reload of STK
#  $navigation_links  << [">Reload",       "/simcontrol/reload",       "Reload the Sim from Source Data Files"]    ## run an IseJob
#  $navigation_links  << [">Kill",         "/simcontrol/kill",         "Terminate the Sim with Extream Violence"]  ## kill an IseJob
  $navigation_links  << [refresh_label,   "/simcontrol/auto_refresh", "Enable/Disable Auto-Refresh"]
                  
  $navigation_links  << ["Launchers",   "/launchers",   "View the Launchers"] 
  $navigation_links  << ["Threats",     "/threats",     "View the Threats"]
  $navigation_links  << ["Statistics",  "/statistics",  "View the Statistics"]
  
  @start_time = SharedMemCache.get('start_time')
  @end_time   = SharedMemCache.get('end_time')

  haml :simcontrol
end


##############################################
## Handle reset to when

get '/simcontrol/reset/:to_when' do |to_when|

  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "Simulation Reset Command Has Been Sent"

  $em2sim.send_data "reset #{to_when}\n"
  
  a_str = "The simulation has been reset to #{to_when} minutes after its start time.  It has also been paused."
  flash a_str
  redirect '/simcontrol'
end

####################
## Launch the IseJob

get '/simcontrol/reload' do
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "Attempt to Reload the Simulation Failed"

   a_str =  "The Reload feature has been disabled by Sim. Control.  Contact Sim. Control at 817-905-1687 for information."

  flash a_str
  redirect '/simcontrol'

#  redirect 'http://138.209.52.147:3000/jobs/launch/6'

end

####################################
## Kill the currently running IseJob

get '/simcontrol/kill' do
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "Attempt to Kill the Current Simulation Failed"

  a_str = "The Kill feature is not yet supported."
  flash a_str
  redirect '/simcontrol'
end

###########################################
## Auto Refresh Controls

get '/simcontrol/auto_refresh' do
  $auto_refresh = !$auto_refresh
  a_str = "Auto-Refresh has been turned #{$auto_refresh ? 'on' : 'off'}."
  a_str << "  The web-page update interval is #{$refresh_interval} seconds."
  flash a_str
  redirect '/simcontrol'
end

###########################################
get '/simcontrol/auto_refresh/:interval' do
  $refresh_interval = params[:interval]
  a_str = "Auto-Refresh interval has been set to #{$refresh_interval} seconds."
  flash a_str
  redirect '/simcontrol'
end



#######################################
## Other Sim. Control supported actions

get '/simcontrol/:action' do |action|

  a_str = "Simulation Command '#{action}' Has Been Sent"
  
  case action.downcase
    when 'start' then
      $em2sim.send_data "start\n"
    when 'stop' then
      $em2sim.send_data "stop\n"
    when 'reset' then
      $em2sim.send_data "reset\n"
      a_str << "\n%p\n  Wait about 30 seconds for the simulation to be completely reset then "
      a_str << "  click on the 'Start' link on the left to cause the simulation to begin processing. "
      a_str << "  If you have auto-refresh active, the simulation time at the top of the page will be reset "
      a_str << "  to the start time.  Once that happens, it will be less than 10 seconds before the simulation starts processing."
    else
      a_str  = "Simulation Command '#{action}' Is Not Valid"
   
  end # end of case :action

  unless $auto_refresh
    a_str << "\n%p\n  <em>Since Auto-Refreshh is not active, you will need to do a manual refresh of this web-page to see the current status of the simulation.</em>"
  end


  
  flash(haml(a_str, :layout => false))
  
  redirect '/simcontrol'
end



###############################
## Stuff Dealing with Launchers

get "/launchers/?" do
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "Launchers"
  
  $launcher_names = SharedMemCache.get 'launcher_names'

  $launchers      = Array.new
  
  $launcher_names.each do |name|
    $launchers << SharedMemCache.get(name)
  end

  $navigation_links  = [["Launchers", "/launchers"] ]


  $launchers.each do |bl|
    $navigation_links << [">#{bl.name}", "/launchers/#{bl.name}"]
  end

  $navigation_links  << ["Threats",     "/threats"]
  $navigation_links  << ["Statistics",  "/statistics"]


  g = Gruff::StackedBar.new
  g.title = "Ordinance Status"
  
  rounds_available = []
  rounds_expended  = []
  
  $launchers.each do |l|
    bl = SharedMemCache.get(l.name)
    rounds_available  << bl.rounds_available
    rounds_expended   << bl.rounds_expended
  end

  g.sort = false
  g.data("Available", rounds_available,  '#00ff00')
  g.data("Expended",  rounds_expended,   '#ff0000')

  g.labels = {}
  
  x = 0
  $launchers.each do |bl|
    g.labels[x] = bl.name.split('_')[1]
    x+=1
  end
  
  graphic_filename = $AADSE_ROOT + "engmngr/stand_in/GUI/public/launcher_ordinance_status.png"

  g.write(graphic_filename)
                     
  haml :launchers
end


##############################################
## Engagement Results for Individual Launchers

get "/launchers/:name" do |name|
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "#{name} Engagement Results"
  @name     = name
  
  @launcher = SharedMemCache.get name
  
  haml "%p That launcher is invalid." unless $launchers.include? name
  
  g = Gruff::Pie.new
  g.title = "#{name} Engagement Results"
  
  @hit   = @launcher.hits
  @miss  = @launcher.misses
  @total = @hit + @miss
  
  g.data("Hit",   @hit,  '#11ee11')
  g.data("Miss",  @miss, '#ee1111')

  graphic_filename = $AADSE_ROOT + "engmngr/stand_in/GUI/public/#{name}_engagement_results.png"

  g.write(graphic_filename)

  haml :engagement_results
end


#############################
## Stuff Dealing with Threats

get "/threats/?" do
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "Threats"
  

  $navigation_links  = [["Launchers",   "/launchers"] ]
  $navigation_links  << ["Threats",     "/threats"]
  
  $active_threats = SharedMemCache.get 'active_threats'

  unless $active_threats.nil?
    $active_threats.each_pair do |k,v|
      $navigation_links << [">#{v[0]}/#{v[1]}", "/threats/#{v[1]}"]
    end
  end



  $navigation_links  << ["Statistics",  "/statistics"]
                
  haml :threats
end

#############################################
get "/threats/:which_threat" do |which_threat|
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "#{which_threat} Threat Details"

  $navigation_links  = [["Launchers",   "/launchers"] ]
  $navigation_links  << ["Threats",     "/threats"]
  
  @which_threat = which_threat

  $active_threats = SharedMemCache.get 'active_threats'

  unless $active_threats.nil?
    $active_threats.each_pair do |k,v|
      $navigation_links << [">#{v[0]}/#{v[1]}", "/threats/#{v[1]}"]
    end
  end

  $navigation_links  << ["Statistics",  "/statistics"]
  
  return haml("%p No details are currently available for active threats.", :layout => true) if $active_threats.nil?

  @threat_data = $active_threats[which_threat]
      
  return haml("%p #{which_threat} is no longer considered active.") unless @threat_data
  
  @threat_object  = SharedMemCache.get(which_threat)
  
  if @threat_object.threat_to
    @toc_object     = SharedMemCache.get("#{@threat_object.threat_to}_toc")
    engagable = @toc_object.can_engage?(@threat_object)   # SMELL: doing this to have engagement zones updated
  else
    engagable = false
  end

  
  if engagable 
    create_ez_graphs( @toc_object,      ## a full TOC object
                      @threat_object)   ## a full threat object -- either Aircraft or Missile
  else
    # FIXME:do what? maybe show something different

    image_path      = $AADSE_ROOT + "engmngr/stand_in/GUI/public" + "#{@which_threat}_ez.png"
    image_path_str  = image_path.to_s
    system("rm -fr "+image_path_str)
  end
                  
  haml :threat_detail
end



################################
## Stuff dealing with Statistics

get "/statistics/?" do
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "Statistics"

  $navigation_links  = [["Launchers",   "/launchers"] ]
  $navigation_links  << ["Threats",     "/threats"]
  $navigation_links  << ["Statistics",  "/statistics"]
  $navigation_links  << [">Cache Usage","/statistics/cache"]

  $stats.each_key do |key|
    $stats[key] = SharedMemCache.get key.to_s
    $stats[key] = [0, "Not Available"] if $stats[key].nil?
  end

  haml :statistics
end


############################
get "/statistics/cache/?" do
  @banner   = "LMMFC/VRSIL  AAD/SE  Simulation"
  @heading  = "SharedMemCache Usage Statistics"

  $navigation_links  = [["Launchers",   "/launchers"] ]
  $navigation_links  << ["Threats",     "/threats"]
  $navigation_links  << ["Statistics",  "/statistics"]
  $navigation_links  << [">Cache Usage","/statistics/cache"]

  haml :cache
end




####################################
## Redirect to the ISEwiki FrontDoor

get '/ise/?' do
  redirect 'http://138.209.52.103/twiki/bin/view/ISEwiki/FrontDoor'
end


###########################################################################################################
## Library of go-bys

get '/test' do
  haml :test
end

get '/whatdb' do
  'We are using the database named ' + options.dbname
end


get '/hi' do
  "Hello World!"
  session["counter"] ||= 0
  session["counter"] += 1

  "You've hit this page #{session["counter"]} time(s)"

end


get '/exit' do
  halt 401, 'go away!'
end


get '/guess/:who' do
  # pass used to go to the next matching route
  pass unless params[:who] == 'Frank'
  "You got me!"
end

get '/guess/*' do
  "You missed!"
end






get '/foo' do
  session[:message] = 'Hello World!  foo'
  redirect '/bar'
end

get '/bar' do
  session[:message]   # => 'Hello World!'
end


get '/hello-world' do
  request.path_info   # => '/hello-world'
  request.fullpath    # => '/hello-world?foo=bar'
  request.url         # => 'http://example.com/hello-world?foo=bar'
  
  "<pre>#{request.inspect}</pre>"
  
end




["/foo2", "/bar2", "/baz2"].each do |path|
  get path do
    "You've reached me at #{request.path_info}"
  end
end





get '/about' do
  "I'm running on Version " + Sinatra::VERSION
end

get '/protected' do
  protected!
  "Welcome, authenticated client"
end


get '/say/*/to/*' do
  # matches /say/hello/to/world
  params["splat"].join(' ') # => ["hello", "world"]
end

get '/download/*.*' do
  # matches /download/path/to/file.xml
  params["splat"] # => ["path/to/file", "xml"]
end


get '/foobar', :agent => /Songbird (\d\.\d)[\d\/]*?/ do
  "You're using Songbird version #{params[:agent][0]}"
end

get '/foobar' do
  # matches non-songbird browsers
end



##############################################################

post '/foo' do
  "You just asked for foo, with post param bar equal to #{params[:bar]}"
end


get '/something' do
  #.. show something ..
  haml :index
end

post '/something' do
  #.. create something ..
end

put '/something' do
  #.. update something ..
end

delete '/something' do
  #.. annihilate something ..
end











###########################################################
=begin
Command line

Sinatra applications can be run directly:

  ruby myapp.rb [-h] [-x] [-e ENVIRONMENT] [-p PORT] [-s HANDLER]

Options are:

  -h # help
  -p # set the port (default is 4567)
  -e # set the environment (default is development)
  -s # specify rack server/handler (default is thin)
  -x # turn on the mutex lock (default is off)

require 'sinatra/base'

class MyApp < Sinatra::Base
  set :sessions, true
  set :foo, 'bar'

  get '/' do
    'Hello world!'
  end
end


MyApp.run! :host => 'localhost', :port => 9090

=end

=begin

This is what you can get from the 'env' hash ....

{"SERVER_NAME"=>"138.209.52.103",
"rack.request.cookie_hash"=>{"Bugzilla_logincookie"=>"xPev38SGFZ",
"TWIKISID"=>"013889c7d1242dfa908f97acda11972b",
"TWIKIPREF"=>"|TwistyContrib_topicattachmentslist=1"},
"async.callback"=>#,
"rack.url_scheme"=>"http",
"HTTP_ACCEPT_ENCODING"=>"gzip,deflate",
"HTTP_USER_AGENT"=>"Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.3) Gecko/20090909 Fedora/3.5.3-1.fc11 Firefox/3.5.3",
"PATH_INFO"=>"/simcontrol/launch",
"rack.run_once"=>false,
"rack.input"=>#,
"SCRIPT_NAME"=>"",
"SERVER_PROTOCOL"=>"HTTP/1.1",
"HTTP_CACHE_CONTROL"=>"max-stale=0",
"HTTP_AUTHORIZATION"=>"Basic YWFkc2U6YWFkc2U=",
"HTTP_ACCEPT_LANGUAGE"=>"en-us,en;q=0.5",
"HTTP_HOST"=>"138.209.52.103:4567",
"rack.errors"=>#,
"REMOTE_ADDR"=>"138.209.111.74",
"REQUEST_PATH"=>"/simcontrol/launch",
"SERVER_SOFTWARE"=>"thin 1.2.4 codename Flaming Astroboy",
"rack.request.cookie_string"=>"TWIKIPREF=%7CTwistyContrib_topicattachmentslist%3D1; Bugzilla_logincookie=xPev38SGFZ; TWIKISID=013889c7d1242dfa908f97acda11972b",
"HTTP_REFERER"=>"http://138.209.52.103:4567/simcontrol",
"rack.request.form_input"=>#,
"rack.request.query_hash"=>{},
"HTTP_COOKIE"=>"TWIKIPREF=%7CTwistyContrib_topicattachmentslist%3D1; Bugzilla_logincookie=xPev38SGFZ; TWIKISID=013889c7d1242dfa908f97acda11972b",
"HTTP_ACCEPT_CHARSET"=>"ISO-8859-1,utf-8;q=0.7,*;q=0.7",
"HTTP_VERSION"=>"HTTP/1.1",
"rack.multithread"=>false,
"rack.version"=>[1,
0],
"rack.request.form_vars"=>"",
"async.close"=>#,
"HTTP_X_BLUECOAT_VIA"=>"A423BD4E0CFBA66D",
"REQUEST_URI"=>"/simcontrol/launch",
"rack.multiprocess"=>false,
"SERVER_PORT"=>"4567",
"rack.request.form_hash"=>{},
"rack.request.query_string"=>"",
"REMOTE_USER"=>"aadse",
"rack.session.options"=>{:expire_after=>2592000,
:secret=>"ISE-is-nice",
:key=>"rack.session",
:path=>"/",
:domain=>"lmmfc-vrsil.com"},
"QUERY_STRING"=>"",
"GATEWAY_INTERFACE"=>"CGI/1.2",
"rack.session"=>{},
"HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
"HTTP_CONNECTION"=>"Keep-Alive",
"REQUEST_METHOD"=>"GET"}

=end

__END__















