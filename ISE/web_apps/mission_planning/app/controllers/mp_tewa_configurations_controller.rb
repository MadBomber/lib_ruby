class MpTewaConfigurationsController < ApplicationController
  # GET /mp_tewa_configurations
  # GET /mp_tewa_configurations.xml
  def index
    @mp_tewa_configurations = MpTewaConfiguration.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mp_tewa_configurations }
    end
  end

  # GET /mp_tewa_configurations/1
  # GET /mp_tewa_configurations/1.xml
  def show
    @mp_tewa_configuration = MpTewaConfiguration.find(params[:id])
      
    @mp_tewa_factors = get_tewa_factor_categories

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mp_tewa_configuration }
    end
  end

  # GET /mp_tewa_configurations/new
  # GET /mp_tewa_configurations/new.xml
  def new
    @mp_tewa_configuration = MpTewaConfiguration.new
    
    @mp_tewa_categories = get_tewa_factor_categories
    
    @form_type = :new
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mp_tewa_configuration }
    end
  end

  # GET /mp_tewa_configurations/1/edit
  def edit
    @mp_tewa_configuration = MpTewaConfiguration.find(params[:id])
      
    tewa_values = @mp_tewa_configuration.mp_tewa_values
      
    @mp_tewa_categories = get_tewa_factor_categories
    
    @form_type = :edit
    
#    debug_me('EDIT'){[:@mp_tewa_configuration, :tewa_values, :@mp_tewa_categories, :@form_type]}

  end

  # POST /mp_tewa_configurations
  # POST /mp_tewa_configurations.xml
  def create
    @mp_tewa_configuration = MpTewaConfiguration.new(params[:mp_tewa_configuration])

    respond_to do |format|
      if @mp_tewa_configuration.save
        flash[:notice] = 'MpTewaConfiguration was successfully created.'
        format.html { redirect_to(@mp_tewa_configuration) }
        format.xml  { render :xml => @mp_tewa_configuration, :status => :created, :location => @mp_tewa_configuration }
      else
        @mp_tewa_factors = get_tewa_factor_categories
        
        @form_type = :new
        
        format.html { render :action => "new" }
        format.xml  { render :xml => @mp_tewa_configuration.errors, :status => :unprocessable_entity }
      end
    end
    
    update_other_tewa_configurations(@mp_tewa_configuration)
  end

  # PUT /mp_tewa_configurations/1
  # PUT /mp_tewa_configurations/1.xml
  def update
  
#    debug_me('UPDATE'){:params}
  
    @mp_tewa_configuration = MpTewaConfiguration.find(params[:id])

    respond_to do |format|
      if @mp_tewa_configuration.update_attributes(params[:mp_tewa_configuration])
        flash[:notice] = 'MpTewaConfiguration was successfully updated.'
        format.html { redirect_to(@mp_tewa_configuration) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mp_tewa_configuration.errors, :status => :unprocessable_entity }
      end
    end
    
    update_other_tewa_configurations(@mp_tewa_configuration)
  end

  # DELETE /mp_tewa_configurations/1
  # DELETE /mp_tewa_configurations/1.xml
  def destroy
    @mp_tewa_configuration = MpTewaConfiguration.find(params[:id])
    @mp_tewa_configuration.destroy

    respond_to do |format|
      format.html { redirect_to(mp_tewa_configurations_url) }
      format.xml  { head :ok }
    end
  end
  
  
  ###########################################################
  def update_other_tewa_configurations(mp_tewa_configuration)
    return nil unless mp_tewa_configuration.selected?
    
    @mp_tewa_configurations = MpTewaConfiguration.all
    
    @mp_tewa_configurations.each do |tewa_configuration|
      next if tewa_configuration.name == mp_tewa_configuration.name
      
      tewa_configuration.update_attributes(:selected => false)
    end
  end
  
  
  ##############################
  def get_tewa_factor_categories
    tewa_values = @mp_tewa_configuration.mp_tewa_values
          
    mp_tewa_factors = Hash.new
    
    MpTewaFactor.categories.each do |category_name|
      mp_tewa_factors[category_name] = Hash.new
       
      unless tewa_values.empty?
        tewa_values.each do |tewa_value|
          if tewa_value.mp_tewa_factor.category == category_name.to_s
            mp_tewa_factors[category_name][tewa_value.mp_tewa_factor.name] = tewa_value
          end
        end
      else
        MpTewaFactor.method(category_name.to_s.pluralize).call.each do |factor|
          mp_tewa_factors[category_name][factor.name] = MpTewaValue.new(:mp_tewa_configuration => @mp_tewa_configuration, :mp_tewa_factor => factor, :value => 0)
        end
      end
    end
    
    return mp_tewa_factors
  end
  
end
