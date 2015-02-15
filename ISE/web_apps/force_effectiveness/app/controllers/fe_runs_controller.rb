###############################################
###
##   File:   fe_runs_controller.rb
##   Desc:   Run model interface.
##
#

require 'fe_summary'
require 'fe_query'

class FeRunsController < ApplicationController
  include FeSummary
  include FeQuery
  
  ##############################################################################
  ##                         Basic Controller Methods                         ##
  ##############################################################################
  
  #########
  # GET /fe_runs
  # GET /fe_runs.xml
  def index
    @fe_runs = FeRun.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fe_runs }
    end
  end ## def index

  
  ########
  # GET /fe_runs/1
  def show
    @run_id = params[:id]
    @fe_run = FeRun.run(@run_id)[0]
    
    get_summary_stats
      
    get_query_arrays
      
  end ## def show

  
  #######
  # GET /fe_runs/new
  # GET /fe_runs/new.xml
  def new
    @fe_run = FeRun.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fe_run }
    end
  end ## def new

  
  ########
  # GET /fe_runs/1/edit
  def edit
    @fe_run = FeRun.find(params[:id])
  end ## def edit

  
  ##########
  # POST /fe_runs
  # POST /fe_runs.xml
  def create
    @fe_run = FeRun.new(params[:fe_run])

    respond_to do |format|
      if @fe_run.save
        flash[:notice] = 'FeRun was successfully created.'
        format.html { redirect_to(@fe_run) }
        format.xml  { render :xml => @fe_run, :status => :created, :location => @fe_run }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fe_run.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def create

  
  ##########
  # PUT /fe_runs/1
  # PUT /fe_runs/1.xml
  def update
    @fe_run = FeRun.find(params[:id])

    respond_to do |format|
      if @fe_run.update_attributes(params[:fe_run])
        flash[:notice] = 'FeRun was successfully updated.'
        format.html { redirect_to(@fe_run) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fe_run.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def update

  
  ###########
  # DELETE /fe_runs/1
  # DELETE /fe_runs/1.xml
  def destroy
    @fe_run = FeRun.find(params[:id])
    @fe_run.destroy

    respond_to do |format|
      format.html { redirect_to(fe_runs_url) }
      format.xml  { head :ok }
    end
  end ## def destroy
  
  def stats_charts
    #do stuff?
    head :ok
  end
  
  
  ##############################################################################
  ##                             New Event Methods                            ##
  ##############################################################################
  
  ###################################
  # Process received start frame
  #   info: {:frame, :id}
  def self.start_frame_received(info)
    fe_run = FeRun.find_by_id(info[:id])
      
    if fe_run.nil?
      self.create(info)
    else
      #fe_run.update_run(info)
      fe_run.last_frame = info[:frame]
      fe_run.save
    end
  end ## def self.start_frame_received(info)
  
  

  def self.aadse_run_config_received(info)
    fe_run = FeRun.find_by_id(info[:id])
    
    fe_run.mps_idp_name = info[:mps_idp_name]
    fe_run.mps_sg_name  = info[:mps_sg_name]
    fe_run.mptc_name    = info[:mptc_name]
    
    fe_run.save
  
  end
   
    
  
  
  ##############################################################################
  ##                           Private Class Methods                          ##
  ##############################################################################
  private
  
  #####################
  # Create a new run in the database
  #   info: {:first_frame, :first_time, :id, :last_frame, :last_time,
  #          :mp_scenario_id, :mp_tewa_configuration_id}
  def self.create(info)
    #run_info = self.process_run_info(info)
    run_info = Hash.new
    
    run_info[:first_frame]              = info[:frame]
    run_info[:id]                       = info[:id]
    run_info[:last_frame]               = info[:frame]
#    run_info[:mp_scenario_id]           = 1000
#    run_info[:mp_tewa_configuration_id] = 1000
    
    fe_run = FeRun.new(run_info)
    
    # Have to set id seperately since this isn't automatic.
    fe_run.id = run_info[:id]
    
    fe_run.save
  end ## def self.create(info)
  

  
    
end ## class FeRunsController < ApplicationController
