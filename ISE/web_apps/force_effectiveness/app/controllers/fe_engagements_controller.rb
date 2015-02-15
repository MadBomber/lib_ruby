###############################################
###
##   File:   fe_engagements_controller.rb
##   Desc:   Engagement model interface.
##
#

class FeEngagementsController < ApplicationController
  ##############################################################################
  ##                         Basic Controller Methods                         ##
  ##############################################################################

  #########
  # GET /fe_engagements
  # GET /fe_engagements.xml
  def index
    @fe_engagements = FeEngagement.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fe_engagements }
    end
  end ## def index

  
  ########
  # GET /fe_engagements/1
  # GET /fe_engagements/1.xml
  def show
    @fe_engagement = FeEngagement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fe_engagement }
    end
  end ## def show

  
  #######
  # GET /fe_engagements/new
  # GET /fe_engagements/new.xml
  def new
    @fe_engagement = FeEngagement.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fe_engagement }
    end
  end ## def new

  
  ########
  # GET /fe_engagements/1/edit
  def edit
    @fe_engagement = FeEngagement.find(params[:id])
  end ## def edit

  
  ##########
  # POST /fe_engagements
  # POST /fe_engagements.xml
  def create
    @fe_engagement = FeEngagement.new(params[:fe_engagement])

    respond_to do |format|
      if @fe_engagement.save
        flash[:notice] = 'FeEngagement was successfully created.'
        format.html { redirect_to(@fe_engagement) }
        format.xml  { render :xml => @fe_engagement, :status => :created, :location => @fe_engagement }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fe_engagement.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def create

  
  ##########
  # PUT /fe_engagements/1
  # PUT /fe_engagements/1.xml
  def update
    @fe_engagement = FeEngagement.find(params[:id])

    respond_to do |format|
      if @fe_engagement.update_attributes(params[:fe_engagement])
        flash[:notice] = 'FeEngagement was successfully updated.'
        format.html { redirect_to(@fe_engagement) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fe_engagement.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def update

  
  ###########
  # DELETE /fe_engagements/1
  # DELETE /fe_engagements/1.xml
  def destroy
    @fe_engagement = FeEngagement.find(params[:id])
    @fe_engagement.destroy

    respond_to do |format|
      format.html { redirect_to(fe_engagements_url) }
      format.xml  { head :ok }
    end
  end ## def destroy
  
  
  ##############################################################################
  ##                               Find Methods                               ##
  ##############################################################################
  
  ##############
  # Find an engagement in the database.
  #   info: {:fe_run_id, :launcher_label, :threat_label}
  def find(info)
    return FeEngagementsController.find(info)
  end ## def find(info)
  
  
  ###################
  # Find an engagement in the database.
  #   info: {:fe_run_id, :launcher_label, :threat_label}
  def self.find(info)
    launcher_id = FeLaunchersController.find(info).id
    threat_id   = FeThreatsController.find(info).id
    
    return FeEngagement.run(info[:fe_run_id]).find_by_fe_launcher_id_and_fe_threat_id(launcher_id, threat_id)
  end ## def self.find(info)
  
  
  ##############################################################################
  ##                             New Event Methods                            ##
  ##############################################################################
  
  #############################
  # Create a new engagement and interceptor in the database.
  #   info: {:fe_run_id, :interceptor_label, :launcher_label, :threat_label}
  def self.threat_engaged(info)
    fe_engagement = self.find(info)
    
    fe_engagement = self.create(info) if fe_engagement.nil?
    
    # Create a new interceptor in the database.
    FeInterceptorsController.interceptor_engaged(fe_engagement, info[:interceptor_label])
    
    return fe_engagement
  end ## def self.threat_engaged(info)
  
  
  ##############################################################################
  ##                           Private Class Methods                          ##
  ##############################################################################
  private
  
  #####################
  # Create a new engagement.
  #   info: {fe_launcher_id, :fe_run_id, :fe_threat_id, :status}
  def self.create(info)
    engagement_info = self.process_engagement_info(info)
    
    fe_engagement = FeEngagement.new(engagement_info)
    
    fe_engagement.save
    
    return fe_engagement
  end ## def self.create_engagement(info)
  
  
  ################################
  # Create a hash for creating a new engagement.
  #   info: {:fe_run_id, :launcher_label, :threat_label, ...}
  def self.process_engagement_info(info)
    engagement_info = Hash.new
    
    fe_launcher = FeLaunchersController.find(info)
    fe_threat   = FeThreatsController.find(info)
    
    engagement_info[:fe_launcher_id] = fe_launcher.id
    engagement_info[:fe_run_id]      = info[:fe_run_id]
    engagement_info[:fe_threat_id]   = fe_threat.id
    engagement_info[:status]         = 'engaging'
      
    return engagement_info
  end ## def self.process_engagement_info(info)
  
end ## class FeEngagementsController < ApplicationController
