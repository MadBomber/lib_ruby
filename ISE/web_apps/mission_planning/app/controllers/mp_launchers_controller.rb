class MpLaunchersController < ApplicationController
  # GET /mp_launchers
  # GET /mp_launchers.xml
  def index
    @mp_launchers = MpLauncher.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mp_launchers }
    end
  end

  # GET /mp_launchers/1
  # GET /mp_launchers/1.xml
  def show
    @mp_launcher = MpLauncher.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mp_launcher }
    end
  end

  # GET /mp_launchers/new
  # GET /mp_launchers/new.xml
  def new
    @mp_launcher = MpLauncher.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mp_launcher }
    end
  end

  # GET /mp_launchers/1/edit
  def edit
    @mp_launcher = MpLauncher.find(params[:id])
  end

  # POST /mp_launchers
  # POST /mp_launchers.xml
  def create
    @mp_launcher = MpLauncher.new(params[:mp_launcher])

    respond_to do |format|
      if @mp_launcher.save
        flash[:notice] = 'MpLauncher was successfully created.'
        format.html { redirect_to(@mp_launcher) }
        format.xml  { render :xml => @mp_launcher, :status => :created, :location => @mp_launcher }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mp_launcher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mp_launchers/1
  # PUT /mp_launchers/1.xml
  def update
    @mp_launcher = MpLauncher.find(params[:id])

    respond_to do |format|
      if @mp_launcher.update_attributes(params[:mp_launcher])
        flash[:notice] = 'MpLauncher was successfully updated.'
        format.html { redirect_to(@mp_launcher) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mp_launcher.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mp_launchers/1
  # DELETE /mp_launchers/1.xml
  def destroy
    @mp_launcher = MpLauncher.find(params[:id])
    @mp_launcher.destroy

    respond_to do |format|
      format.html { redirect_to(mp_launchers_url) }
      format.xml  { head :ok }
    end
  end
end
