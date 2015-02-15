###############################################
###
##   File:   fe_launchers_controller.rb
##   Desc:   Launcher model interface.
##
#

class FeLaunchersController < ApplicationController
  ##############################################################################
  ##                         Basic Controller Methods                         ##
  ##############################################################################
  
  #########
  # GET /fe_launchers
  # GET /fe_launchers.xml
  def index
    @fe_launchers = FeLauncher.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fe_launchers }
    end
  end ## def index

  
  ########
  # GET /fe_launchers/1
  # GET /fe_launchers/1.xml
  def show
    @fe_launcher = FeLauncher.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fe_launcher }
    end
  end ## def show

  
  #######
  # GET /fe_launchers/new
  # GET /fe_launchers/new.xml
  def new
    @fe_launcher = FeLauncher.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fe_launcher }
    end
  end ## def new

  
  ########
  # GET /fe_launchers/1/edit
  def edit
    @fe_launcher = FeLauncher.find(params[:id])
  end ## def edit

  
  ##########
  # POST /fe_launchers
  # POST /fe_launchers.xml
  def create
    @fe_launcher = FeLauncher.new(params[:fe_launcher])

    respond_to do |format|
      if @fe_launcher.save
        flash[:notice] = 'FeLauncher was successfully created.'
        format.html { redirect_to(@fe_launcher) }
        format.xml  { render :xml => @fe_launcher, :status => :created, :location => @fe_launcher }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fe_launcher.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def create

  
  ##########
  # PUT /fe_launchers/1
  # PUT /fe_launchers/1.xml
  def update
    @fe_launcher = FeLauncher.find(params[:id])

    respond_to do |format|
      if @fe_launcher.update_attributes(params[:fe_launcher])
        flash[:notice] = 'FeLauncher was successfully updated.'
        format.html { redirect_to(@fe_launcher) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fe_launcher.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def update

  
  ###########
  # DELETE /fe_launchers/1
  # DELETE /fe_launchers/1.xml
  def destroy
    @fe_launcher = FeLauncher.find(params[:id])
    @fe_launcher.destroy

    respond_to do |format|
      format.html { redirect_to(fe_launchers_url) }
      format.xml  { head :ok }
    end
  end ## def destroy
  
  
  ##############################################################################
  ##                               Find Methods                               ##
  ##############################################################################
  
  ##############
  # Find a launcher in the database.
  #   info: {:fe_run_id, :launcher_label or :label, ...}
  def find(info)
    return FeLaunchersController.find(info)
  end ## def find(info)
  
  
  ###################
  # Find a launcher in the database.
  #   info: {:fe_run_id, :launcher_label or :label, ...}
  def self.find(info)
    label = get_object_label(:launcher, info)
    
    return FeLauncher.run(info[:fe_run_id]).find_by_label(label)
  end ## def self.find(info)
  
  
  ##############################################################################
  ##                             New Event Methods                            ##
  ##############################################################################
  
  ###########################
  # Create a new launcher in the database.
  #   info = {'label', 'run_id'}
  def self.launcher_bid(info)
    self.create(info) unless self.find(info)
  end ## def self.launcher_bid(info) 
  
  
  ##############################################################################
  ##                           Private Class Methods                          ##
  ##############################################################################
  private
  
  #####################
  # Create a new launcher in the database
  #   info: {:category, :fe_run_id, :label}
  def self.create(info)
    launcher_info = self.process_launcher_info(info)
    
    fe_launcher = FeLauncher.new(launcher_info)
    
    fe_launcher.save
  end ## def self.create(info)
  
  
  ####################################
  # Create a hash for creating a new launcher.
  #   info = {:fe_run_id, :label}
  def self.process_launcher_info(info)
    launcher_info = Hash.new
    
    launcher_info[:category]  = fe_object_category(info[:label])
    launcher_info[:fe_run_id] = info[:fe_run_id]
    launcher_info[:label]     = info[:label]
      
    return launcher_info
  end ## def self.process_launcher_info(info)
  
end ## class FeLaunchersController < ApplicationController
