class MpScenariosController < ApplicationController
  # GET /mp_scenarios
  # GET /mp_scenarios.xml
  def index
    @mp_scenarios = MpScenario.all
    
    ## display these interesting columns
    @columns = ['selected',
                'name', 'desc',
                'random_threat_count',
                'idp_name',
                'sg_name'
               ]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mp_scenarios }
    end
  end

  # GET /mp_scenarios/1
  # GET /mp_scenarios/1.xml
  def show
    @mp_scenario = MpScenario.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mp_scenario }
    end
  end

  # GET /mp_scenarios/new
  # GET /mp_scenarios/new.xml
  def new
    @mp_scenario = MpScenario.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mp_scenario }
    end
  end

  # GET /mp_scenarios/1/edit
  def edit
    @mp_scenario = MpScenario.find(params[:id])
  end

  # POST /mp_scenarios
  # POST /mp_scenarios.xml
  def create
    @mp_scenario = MpScenario.new(params[:mp_scenario])

    respond_to do |format|
      if @mp_scenario.save
        flash[:notice] = 'MpScenario was successfully created.'
        format.html { redirect_to(@mp_scenario) }
        format.xml  { render :xml => @mp_scenario, :status => :created, :location => @mp_scenario }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mp_scenario.errors, :status => :unprocessable_entity }
      end
    end
    
    prepare_selected_scenario

  end

  # PUT /mp_scenarios/1
  # PUT /mp_scenarios/1.xml
  def update
    @mp_scenario = MpScenario.find(params[:id])

    respond_to do |format|
      if @mp_scenario.update_attributes(params[:mp_scenario])
        flash[:notice] = 'MpScenario was successfully updated.'
        format.html { redirect_to(@mp_scenario) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mp_scenario.errors, :status => :unprocessable_entity }
      end
    end
   
    prepare_selected_scenario
        
  end

  # DELETE /mp_scenarios/1
  # DELETE /mp_scenarios/1.xml
  def destroy
    @mp_scenario = MpScenario.find(params[:id])
    @mp_scenario.destroy

    respond_to do |format|
      format.html { redirect_to(mp_scenarios_url) }
      format.xml  { head :ok }
    end
  end
  
  ###########################################
  ## Ensure that only one mp_scenario record
  ## is selected, all others must be false
  def update_other_scenarios(mp_scenario)
    return nil unless mp_scenario.selected?
    
    @mp_scenarios = MpScenario.all
    
    @mp_scenarios.each do |scenario|
      next if scenario.name == mp_scenario.name
      
      scenario.update_attributes(:selected => false)
    end
  end


  
  ###########################################
  ## Ensure that only one mp_scenario record
  ## is selected, all others must be false
  ## FIXME: This method is being called EVEN IF THERE IS A VALIDATION ERROR!
  def update_data_trajectories(mp_scenario)
    return nil unless mp_scenario.selected?

    # NOTE: Allow the system call to block the UI to ensure that the user does not attempt
    #       to launch a simulation until after the new trajectory files have been created.
    #       If there is a large number of random threats this may take some noticable time.
    #       The performance is about 3 threats a second... 300 threats would be about a minute and a half.
    # TODO: Consider puttnig this task into a different threat/fiber/whatever and use a flash
    #       message feedback to the user when the task is completed.
    flash[:notice] = 'Removing old trajectory files.'
    system("cd #{ENV['TRAJ_DIR']}; rm -fr *.traj")
    flash[:notice] = 'Creating new trajectory files.'
    system("ruby #{ENV['AADSE_ROOT']}/bin/tbm_threat_generator.rb #{mp_scenario.random_threat_count} ")
    # FIXME: This notification only appears on the server; need AJAXy way to get this kind
    #        of notification to the web browser (client)
    Notify.notify("Scenario Ready","The IDP/SG scenario data is ready for simulation.")
    flash[:notice] = 'Scenario is ready for simulation.'
  end

  ###########################################
  ## Sycronize the IDP/SG Directories with those
  ## on the MS Windoze computer.
  def sycronize_idp_sg(mp_scenario)
    # Only sync if the user has selected this scenario AND
    # the sync service is alive.
    return nil unless (mp_scenario.selected? and sync_idp_sg_service_alive?)

    # fetch the IDP and SG scenarios selected
    $sync_idp_sg_service.rsync_idp_sg( ENV['IPADDRESS'], mp_scenario.idp_name, mp_scenario.sg_name )
    
  end ## end of def sycronize_idp_sg(mp_scenario)

  #####################################################################################
  def sync_idp_sg_service_alive?
    begin
      $sync_idp_sg_service.alive?
    rescue DRb::DRbConnError
      STDERR.puts "got DRb::DRbConnError"
      false
    end    
  end

  ######################################################################################
  def prepare_selected_scenario
    unless @mp_scenario.has_errors?
      # set other scenarios to not selected if this is selected
      update_other_scenarios(@mp_scenario)
      
      # Sycronize the IDP nad SG scenario directories as necessary
      sycronize_idp_sg(@mp_scenario)
      
      # Cause UI to wait until trajectory files have been created
      update_data_trajectories(@mp_scenario)
    end
  end

end ## end of class MpScenariosController < ApplicationController
