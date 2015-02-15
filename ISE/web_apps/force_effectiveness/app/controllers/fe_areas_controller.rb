###############################################
###
##   File:   fe_areas_controller.rb
##   Desc:   Area model interface.
##
#

class FeAreasController < ApplicationController
  ##############################################################################
  ##                         Basic Controller Methods                         ##
  ##############################################################################
  
  #########
  # GET /fe_areas
  # GET /fe_areas.xml
  def index
    @fe_areas = FeArea.all
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fe_areas }
    end
  end ## def index
  
  
  ########
  # GET /fe_areas/1
  # GET /fe_areas/1.xml
  def show
    @fe_area = FeArea.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fe_area }
    end
  end ## def show
  
  
  #######
  # GET /fe_areas/new
  # GET /fe_areas/new.xml
  def new
    @fe_area = FeArea.new
  
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fe_area }
    end
  end ## def new
  
  
  ########
  # GET /fe_areas/1/edit
  def edit
    @fe_area = FeArea.find(params[:id])
  end ## def edit
  
  
  ##########
  # POST /fe_areas
  # POST /fe_areas.xml
  def create
    @fe_area = FeArea.new(params[:fe_area])
  
    respond_to do |format|
      if @fe_area.save
        flash[:notice] = 'FeArea was successfully created.'
        format.html { redirect_to(@fe_area) }
        format.xml  { render :xml => @fe_area, :status => :created, :location => @fe_area }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fe_area.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def create
  
  
  ##########
  # PUT /fe_areas/1
  # PUT /fe_areas/1.xml
  def update
    @fe_area = FeArea.find(params[:id])
  
    respond_to do |format|
      if @fe_area.update_attributes(params[:fe_area])
        flash[:notice] = 'FeArea was successfully updated.'
        format.html { redirect_to(@fe_area) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fe_area.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def update
  
  
  ###########
  # DELETE /fe_areas/1
  # DELETE /fe_areas/1.xml
  def destroy
    @fe_area = FeArea.find(params[:id])
    @fe_area.destroy
  
    respond_to do |format|
      format.html { redirect_to(fe_areas_url) }
      format.xml  { head :ok }
    end
  end ## def destroy
  
  
  ##############################################################################
  ##                               Find Methods                               ##
  ##############################################################################
  
  ##############
  # Find an area in the database.
  #   info: {:fe_run_id, :label}
  def find(info, category = nil)
    return FeAreasController.find(info, category)
  end ## def find(info)
  
  
  ###################
  # Find an area in the database.
  # if category is nil then
  #   info: {:fe_run_id, :label}
  # else
  #   info: {:category, :fe_run_id, :label, :source_area, :target_area}
  #   category: Category of area in database.
  def self.find(info, category = nil)
    case category
    ##########################
    when :source, :target then
      find_hash = get_find_hash(info, category)
      
      fe_area = self.find(find_hash)
      
    #############
    when nil then
      fe_area = FeArea.run(info[:fe_run_id]).find_by_label(info[:label])
        
    ####
    else
      raise trace_error("Area had unexpected category: #{category}.")
    end ## case category
      
    return fe_area
  end ## def self.find
  
  
  ##############################################################################
  ##                             New Event Methods                            ##
  ##############################################################################
  
  #############################
  # Create a new area in the database.
  #   threat_info: {:category, :fe_run_id, :label, :source_area, :target_area}
  def self.area_launched(threat_info)
    return nil if threat_info[:source_area].nil?
    
    self.create(threat_info, :source) unless self.find(threat_info, :source)
  end ## def self.area_launched(threat_info)
  
  
  #############################
  # Create a new area in the database.
  #   threat_info: {:category, :fe_run_id, :label, :source_area, :target_area}
  def self.area_threatened(threat_info)
    self.create(threat_info, :target) unless self.find(threat_info, :target)
  end ## def self.area_threatened(threat_info)
  
  
  ##############################################################################
  ##                           Private Class Methods                          ##
  ##############################################################################
  private
  
  #####################
  # Create a new area
  #   info: {:category, :fe_run_id, :label}
  def self.create(threat_info, category)
    area_info = self.process_area_info(threat_info, category)
    
    fe_area = FeArea.new(area_info)
      
    fe_area.save
  end ## def self.create
  
  
  #############################################
  # Get hash to find an area from a threat_info hash
  #   threat_info: {:category, :fe_run_id, :label, :source_area, :target_area}
  #   category: Category of area to find.
  def self.get_find_hash(threat_info, category)
    find_hash = Hash.new
    
    find_hash[:fe_run_id] = threat_info[:fe_run_id]
    
    case category
    #################
    when :source then
      find_hash[:label] = threat_info[:source_area]
      
    #################
    when :target then
      find_hash[:label] = threat_info[:target_area]
      
    ####
    else
      raise trace_error("Area had unexpected category: #{category}.")
    end ## case category
    
    return find_hash
  end ## def self.get_find_hash(info, category)
  
  
  #################################################
  # Create a hash for creating a new threat.
  #   threat_info: {:category, :fe_run_id, :label, :source_area, :target_area}
  #   category: Category of area to process
  def self.process_area_info(threat_info, category)
    area_info = get_find_hash(threat_info, category)
    
    area_info[:category]       = category.to_s
      
    return area_info
  end ## def self.process_area_info(threat_info, category)
    
end ## class FeAreasController < ApplicationController
