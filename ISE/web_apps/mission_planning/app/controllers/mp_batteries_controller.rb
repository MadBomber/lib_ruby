class MpBatteriesController < ApplicationController
  # GET /mp_batteries
  # GET /mp_batteries.xml
  def index
    @mp_batteries = MpBattery.all
    @columns = ['name', 'desc', 'mp_launchers'] ## interesting columns

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mp_batteries }
    end
  end

  # GET /mp_batteries/1
  # GET /mp_batteries/1.xml
  def show
    @mp_battery = MpBattery.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mp_battery }
    end
  end

  # GET /mp_batteries/new
  # GET /mp_batteries/new.xml
  def new
    @mp_battery = MpBattery.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mp_battery }
    end
  end
  
  # GET /mp_batteries/1/edit
  def edit
    @mp_battery = MpBattery.find(params[:id])
    @mp_battery_configurations = @mp_battery.mp_battery_configurations
    @mp_launchers = @mp_battery.mp_launchers
  end

  # POST /mp_batteries
  # POST /mp_batteries.xml
  def create
    @mp_battery = MpBattery.new(params[:mp_battery])

    respond_to do |format|
      if @mp_battery.save
        flash[:notice] = 'MpBattery was successfully created.'
        format.html { redirect_to(@mp_battery) }
        format.xml  { render :xml => @mp_battery, :status => :created, :location => @mp_battery }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mp_battery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mp_batteries/1
  # PUT /mp_batteries/1.xml
  def update
    @mp_battery = MpBattery.find(params[:id])

    respond_to do |format|
      if @mp_battery.update_attributes(params[:mp_battery])
        flash[:notice] = 'MpBattery was successfully updated.'
        format.html { redirect_to(@mp_battery) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mp_battery.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mp_batteries/1
  # DELETE /mp_batteries/1.xml
  def destroy
    @mp_battery = MpBattery.find(params[:id])
    @mp_battery.destroy

    respond_to do |format|
      format.html { redirect_to(mp_batteries_url) }
      format.xml  { head :ok }
    end
  end
end
