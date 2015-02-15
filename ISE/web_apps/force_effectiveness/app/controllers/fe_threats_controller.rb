###############################################
###
##   File:   fe_threats_controller.rb
##   Desc:   Threat model interface.
##
#

class FeThreatsController < ApplicationController
  ##############################################################################
  ##                         Basic Controller Methods                         ##
  ##############################################################################
  
  #########
  # GET /fe_threats
  # GET /fe_threats.xml
  def index
    @fe_threats = FeThreat.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fe_threats }
    end
  end ## def index

  
  ########
  # GET /fe_threats/1
  # GET /fe_threats/1.xml
  def show
    @fe_threat = FeThreat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fe_threat }
    end
  end ## def show

  
  #######
  # GET /fe_threats/new
  # GET /fe_threats/new.xml
  def new
    @fe_threat = FeThreat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fe_threat }
    end
  end ## def new

  
  ########
  # GET /fe_threats/1/edit
  def edit
    @fe_threat = FeThreat.find(params[:id])
  end ## def edit

  
  ##########
  # POST /fe_threats
  # POST /fe_threats.xml
  def create
    @fe_threat = FeThreat.new(params[:fe_threat])

    respond_to do |format|
      if @fe_threat.save
        flash[:notice] = 'FeThreat was successfully created.'
        format.html { redirect_to(@fe_threat) }
        format.xml  { render :xml => @fe_threat, :status => :created, :location => @fe_threat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fe_threat.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def create

  
  ##########
  # PUT /fe_threats/1
  # PUT /fe_threats/1.xml
  def update
    @fe_threat = FeThreat.find(params[:id])

    respond_to do |format|
      if @fe_threat.update_attributes(params[:fe_threat])
        flash[:notice] = 'FeThreat was successfully updated.'
        format.html { redirect_to(@fe_threat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fe_threat.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def update

  
  ###########
  # DELETE /fe_threats/1
  # DELETE /fe_threats/1.xml
  def destroy
    @fe_threat = FeThreat.find(params[:id])
    @fe_threat.destroy

    respond_to do |format|
      format.html { redirect_to(fe_threats_url) }
      format.xml  { head :ok }
    end
  end ## def destroy
  
  
  ##############################################################################
  ##                               Find Methods                               ##
  ##############################################################################
  
  ##############
  # Find a threat in the database
  #   info: {:fe_run_id, :threat_label or :label, ...}
  def find(info)
    return FeThreatsController.find(info)
  end ## def find(info)
  
  
  #######################
  # Get threat from database.
  #   info: {:threat_label or :label, :fe_run_id, ...}
  def self.find(info)
    label = get_object_label(:threat, info)
    
    return FeThreat.run(info[:fe_run_id]).find_by_label(label)
  end ## def self.threat(info)
  
  
  ##############################################################################
  ##                             New Event Methods                            ##
  ##############################################################################
  
  #############################
  # Create a new threat in the database.
  #   info: {:category, :fe_run_id, :label, :source_area, :target_area}
  def self.threat_detected(info)
    FeAreasController.area_launched(info)
    FeAreasController.area_threatened(info)
    
    self.create(info) unless self.find(info)
  end ## def self.create(info)
  
  
  ###############################
  # Record threat destruction in database.
  #   info: {:label, :run_id}
  def self.threat_destroyed(info)
    self.set_threat_status(info, :destroyed)
  end ## def self.threat_destroyed(info)


  ##############################
  # Record threat impact in database.
  #   info: {:label, :run_id}
  def self.threat_impacted(info)
    self.set_threat_status(info, :impacted)
  end ## def self.threat_impacted(info)
  
  
  ##############################################################################
  ##                           Private Class Methods                          ##
  ##############################################################################
  private
  
  #####################
  # Create a new threat.
  #   info: {:category, :fe_run_id, :label, :source_area, :target_area}
  def self.create(info)
    threat_info = self.process_threat_info(info)
    
    fe_threat = FeThreat.new(threat_info)
    
    fe_threat.save
  end ## def self.create_engagement(info)
  
  
  ##################################
  # Create a hash for creating a new threat.
  #   info: {:category, :fe_run_id, :label, :source_area, :target_area}
  def self.process_threat_info(info)
    source_area = FeAreasController.find(info, :source)
    target_area = FeAreasController.find(info, :target)
    
    threat_info = Hash.new
    
    threat_info[:category]       = info[:category]
    threat_info[:fe_run_id]      = info[:fe_run_id]
    threat_info[:source_area_id] = source_area.id unless source_area.nil?
    threat_info[:target_area_id] = target_area.id
    threat_info[:label]          = info[:label]
    threat_info[:status]         = 'flying'
      
    return threat_info
  end ## def self.process_threat_info(info)
  
  
  ########################################
  # Store new status for a threat in the database
  #   info: {:label, :fe_run_id, ...}
  #   status:   status of threat's engagement
  def self.set_threat_status(info, status)
    fe_threat = self.find(info)
        
    fe_threat.status = status.to_s
    
    fe_threat.save
    
    fe_threat.fe_engagements.each do |engagement|
      engagement.update_engagement
    end
  end ## def self.set_threat_status(info, status)
  
end ## class FeThreatsController < ApplicationController
