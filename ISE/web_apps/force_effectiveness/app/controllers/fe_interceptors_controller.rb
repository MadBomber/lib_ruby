###############################################
###
##   File:   fe_interceptors_controller.rb
##   Desc:   Interceptor model interface.
##
#

class FeInterceptorsController < ApplicationController
  ##############################################################################
  ##                         Basic Controller Methods                         ##
  ##############################################################################
  
  #########
  # GET /fe_interceptors
  # GET /fe_interceptors.xml
  def index
    @fe_interceptors = FeInterceptor.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fe_interceptors }
    end
  end ## def index

  
  ########
  # GET /fe_interceptors/1
  # GET /fe_interceptors/1.xml
  def show
    @fe_interceptor = FeInterceptor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fe_interceptor }
    end
  end ## def show

  
  #######
  # GET /fe_interceptors/new
  # GET /fe_interceptors/new.xml
  def new
    @fe_interceptor = FeInterceptor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fe_interceptor }
    end
  end ## def new

  
  ########
  # GET /fe_interceptors/1/edit
  def edit
    @fe_interceptor = FeInterceptor.find(params[:id])
  end ## def edit

  
  ##########
  # POST /fe_interceptors
  # POST /fe_interceptors.xml
  def create
    @fe_interceptor = FeInterceptor.new(params[:fe_interceptor])

    respond_to do |format|
      if @fe_interceptor.save
        flash[:notice] = 'FeInterceptor was successfully created.'
        format.html { redirect_to(@fe_interceptor) }
        format.xml  { render :xml => @fe_interceptor, :status => :created, :location => @fe_interceptor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fe_interceptor.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def create

  
  ##########
  # PUT /fe_interceptors/1
  # PUT /fe_interceptors/1.xml
  def update
    @fe_interceptor = FeInterceptor.find(params[:id])

    respond_to do |format|
      if @fe_interceptor.update_attributes(params[:fe_interceptor])
        flash[:notice] = 'FeInterceptor was successfully updated.'
        format.html { redirect_to(@fe_interceptor) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fe_interceptor.errors, :status => :unprocessable_entity }
      end
    end ## respond_to do |format|
  end ## def update

  
  ###########
  # DELETE /fe_interceptors/1
  # DELETE /fe_interceptors/1.xml
  def destroy
    @fe_interceptor = FeInterceptor.find(params[:id])
    @fe_interceptor.destroy

    respond_to do |format|
      format.html { redirect_to(fe_interceptors_url) }
      format.xml  { head :ok }
    end
  end ## def destroy
  
  
  ##############################################################################
  ##                               Find Methods                               ##
  ##############################################################################
  
  ##############
  # Find an interceptor in the database.
  #   info: {:fe_run_id, :interceptor_label or :label, ...}
  def find(info)
    return FeInterceptorsController.find(info)
  end ## def find(info)
  
  
  ###################
  # Find an interceptor in the database.
  #   info: {:fe_run_id, :interceptor_label or :label, ...}
  def self.find(info)
    label = get_object_label(:interceptor, info)
    
    return FeInterceptor.run(info[:fe_run_id]).find_by_label(label)
  end ## def self.find(info)
  
  
  ##############################################################################
  ##                             New Event Methods                            ##
  ##############################################################################
  
  ##################################################
  # Create a new interceptor in the database
  #   fe_engagement: The engagement associated with this interceptor.
  #   label: The label of this interceptor. 
  def self.interceptor_engaged(fe_engagement, label)
    find_hash = {
      :fe_run_id => fe_engagement.fe_run_id,
      :label     => label
    }
    
    self.create(fe_engagement, label) unless self.find(find_hash)
  end ## def self.interceptor_engaged(fe_engagement, label)
  
  
  ##############################
  # Record interceptor hit in database.
  #   info: {:fe_run_id, :label}
  def self.interceptor_hit(info)
    self.set_interceptor_status(info, :hit)
  end ## def self.interceptor_hit(info)
  
  
  #################################
  # Record interceptor miss in database.
  #   info: {:fe_run_id, :label}
  def self.interceptor_missed(info)
    self.set_interceptor_status(info, :missed)
  end ## def self.interceptor_missed(info)
  
  
  #####################################
  # Record type of interceptor termination in database.
  #   info: {:fe_run_id, :label, :self_destruct}
  def self.interceptor_terminated(info)
    status = info[:self_destruct] ? :destroyed : :canceled
    
    self.set_interceptor_status(info, status)
  end ## def self.interceptor_terminated(info)
  
  
  ##############################################################################
  ##                           Private Class Methods                          ##
  ##############################################################################
  private
  
  #####################
  # Create a new interceptor in the database
  #   fe_engagement: The engagement associated with this interceptor.
  #   label: The label of this interceptor.
  def self.create(fe_engagement, label)
    interceptor_info = self.process_interceptor_info(fe_engagement, label)
    
    fe_interceptor = FeInterceptor.new(interceptor_info)
    
    fe_interceptor.save
  end ## def self.create(info)
  
  
  #############################################
  # Store new status for an interceptor in the database
  #   info: {:label, :run_id, ...}
  #   status:   status of interceptor's engagement
  def self.set_interceptor_status(info, status)
    @fe_interceptor = self.find(info)
        
    @fe_interceptor.status = status.to_s
    
    @fe_interceptor.save
    
    @fe_interceptor.fe_engagement.update_engagement
  end ## def self.set_interceptor_status(info, status)
  
  
  #######################################################
  # Create a hash for creating a new interceptor.
  #   fe_engagement: The engagement associated with this interceptor.
  #   label: The label of this interceptor.
  def self.process_interceptor_info(fe_engagement, label)
    int_info = Hash.new
    
    int_info[:category]         = fe_object_category(label)
    int_info[:fe_engagement_id] = fe_engagement.id
    int_info[:fe_run_id]        = fe_engagement.fe_run_id
    int_info[:label]            = label
    int_info[:status]           = 'engaging'
      
    return int_info
  end ## def self.process_interceptor_info(fe_engagement, label)
  
end ## class FeInterceptorsController < ApplicationController
