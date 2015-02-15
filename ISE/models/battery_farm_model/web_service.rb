########################################################################
###
##  File: web_service.rb
##  Desc: Example of how to use a sinatra web application as an embedded
##        web service inside a normal IseModel
##
##        Since IseModels can deal with a large number of IseMessages
##        per second, the user response time on a web service may be several
##        seconds.
##
##        Using the current IseRubyPeer there can only be one sinatra web-service
##        per IseRubyModel.
#

require 'sinatra'
module BatteryFarmModel

  class MyWebService < Sinatra::Base

    # These two global options must be specified for use by the RubyPeer  
    $OPTIONS[:web_service]          = self              # Only one sinatra web service per model
    $OPTIONS[:web_service_options]  = {:port => 4567}   # FIXME: User must coordinate port for all
                                                        #        IseModels on a node that have web-services

    # All Sinatra options are available for use.

    class MyCustomApplicationSpecificError < Exception; end

    configure :production do
      not_found do
        "We're so sorry, but we don't know what this is"
      end

      error do
        "Something really nasty happened.  We're on it!"
      end
    end



    # static files come from ./public
    set :public, File.dirname(__FILE__) + '/public'

    # daynamic views are rendered out of ./views
    set :views, File.dirname(__FILE__) + '/views'




    ####################################################
    ## code to handle responses to event errors

    not_found do
      'This is nowhere to be found'
    end

    error do
      'Sorry there was a nasty error - ' + request.env['sinatra.error'].name
    end

    error MyCustomApplicationSpecificError do
      'So what happened was...' + request.env['sinatra.error'].message
    end



    ###################################################
    ## session management tools

    enable :sessions

=begin
use Rack::Session::Cookie, :key => 'rack.session',
                           :domain => 'foo.com',
                           :path => '/',
                           :expire_after => 2592000, # In seconds
                           :secret => 'change_me'

=end

    #############################################
    ## Rakc middleware support for authentication

    use Rack::Auth::Basic do |username, password|
      [username, password] == ['admin', 'admin']
    end


    ## define helpers for more grandular authentication to specific URLS

    helpers do

      def protected!
        response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth") and \
        throw(:halt, [401, "Not authorized\n"]) and \
        return unless authorized?
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
      end

    end



    #######################################
    ## Generic helpers

    helpers do
      def em(text)
        "<em>#{text}</em>"
      end
    end

    helpers do
     include Rack::Utils
     alias_method :h, :escape_html
    end

    helpers do
      # Usage: partial :foo
      def partial(page, options={})
        erb page, options.merge!(:layout => false)
      end
    end



    #############################################################
    ## allows specific code to be run 'before' each event/request


    before do
      # .. this code will run before each event ..
    end



    ###############################################################################
    ## Application specific constants.
    VALID_THREAT_TYPES  = ['abt', 'tbm']
    VALID_TRUTH_TYPES   = ['on', 'true', 'set']   # if its not one of these, use false
    
    ###############################################################################
    ## Root index
    get '/' do
      r_str  = "<p>hello from sinatra running as #{$OPTIONS[:web_service]}</p>"
      r_str += "<p>Auto-engage TBM: #{$OPTIONS[:auto_engage_tbm]}</p>"
      r_str += "<p>Auto-engage ABT: #{$OPTIONS[:auto_engage_abt]}</p>"
      
      r_str += "<br /><br />"
      r_str += "Here is some farm info:"
      r_str += "<br /><br />"
      
      BatteryFarmModel::FARM.each do |k, v|
        r_str += "k: #{k} v.label: #{v.label}<br />"
      end
      
      body r_str
    end
    
    ###############################################################################
    ## change value of $debug
    get '/debug/:state' do |s|
      $debug = VALID_TRUTH_TYPES.include?(s.downcase)
      body "set $debug to #{$debug}"
    end
    
    
    ###############################################################################
    ## Utility helper function to DRYup some code
    def set_auto_engage(threat_type, state=true)
      threat_type = threat_type.downcase
      if VALID_THREAT_TYPES.include?(threat_type)
        key = ("auto_engage_" + threat_type).to_sym
        $OPTIONS[key] = state
        ISE::Log.info "User has turned #{key} #{state ? 'on' : 'off'} using a web service."
        return true
      end
      return false
    end
    
    ###############################################################################
    ## change auto-engage state to true
    get '/auto/:threat_type/?' do |t|
      if set_auto_engage(t)
        body "Auto-engage for #{t.upcase} has been turned on."
      else
        body "ERROR: '#{t}' is an unknown option.  Valid threat types are: #{VALID_THREAT_TYPES.join(', ')}"
      end
    end

    ###############################################################################
    ## change auto-engage state to user specified state
    get '/auto/:threat_type/:state' do |t,s|
      state = VALID_TRUTH_TYPES.include?(s.downcase)
      if set_auto_engage(t, state)
        body "Auto-engage for #{t.upcase} has been turned #{state ? 'on' : 'off'}."
      else
        body "ERROR: '#{t}' is an unknown option.  Valid threat types are: #{VALID_THREAT_TYPES.join(', ')}"
      end
    end

 
    
    ###############################################################################
    ## show values for a specific launcher
    
    get '/launcher/:launcher' do |launcher|
      unless FARM.include?(launcher)
        body "#{launcher} is not handled by this IseModel."
      end
      bl = FARM[launcher]
      s = bl.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
      body "<pre>#{s}</pre>"
    end

    
    ###############################################################################
    ## quit
    get '/quit' do
      msg = EndCase.new;  msg.publish
      msg = EndRun.new;   msg.publish
      ISE::Log.info "Terminating simulation via the #{$OPTIONS[:web_service]} web service 'quit' capability."
      body "The EndCase/EndRun IseMessages have been published."
    end


# The following routes demonstrate different typical capability

    ###############
    get '/mkerr' do
      raise MyCustomApplicationSpecificError, 'something bad'
    end


    ############
    get '/hi' do
      "Hello World!"
      session["counter"] ||= 0
      session["counter"] += 1

      "You've hit this page #{session["counter"]} time(s)"

    end


    ###################
    get '/protected' do
      protected!
      "Welcome, authenticated client"
    end


    ################
    get '/search' do
      redirect 'http://www.google.com'  
    end


    ################
    get '/request' do
      r_str = request.pretty_inspect.gsub('<', '&lt;').gsub('>', '&gt;')
    end
    

    ################
    get '/layout' do
      @section = 'main body'
      erb :overview, :layout => :default
    end


 
  end ## end of class MyWebService < Sinatra::Base
  
end ## end of module BatteryFarmModel
