class MpThreatsController < ApplicationController
  # GET /mp_threats
  # GET /mp_threats.xml
  def index
    @mp_threats = MpThreat.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mp_threats }
    end
  end

  # GET /mp_threats/1
  # GET /mp_threats/1.xml
  def show
    @mp_threat = MpThreat.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mp_threat }
    end
  end

  # GET /mp_threats/new
  # GET /mp_threats/new.xml
  def new
    @mp_threat = MpThreat.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mp_threat }
    end
  end

  # GET /mp_threats/1/edit
  def edit
    @mp_threat = MpThreat.find(params[:id])
  end

  # POST /mp_threats
  # POST /mp_threats.xml
  def create
    @mp_threat = MpThreat.new(params[:mp_threat])

    respond_to do |format|
      if @mp_threat.save
        flash[:notice] = 'MpThreat was successfully created.'
        format.html { redirect_to(@mp_threat) }
        format.xml  { render :xml => @mp_threat, :status => :created, :location => @mp_threat }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mp_threat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mp_threats/1
  # PUT /mp_threats/1.xml
  def update
    @mp_threat = MpThreat.find(params[:id])

    respond_to do |format|
      if @mp_threat.update_attributes(params[:mp_threat])
        flash[:notice] = 'MpThreat was successfully updated.'
        format.html { redirect_to(@mp_threat) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mp_threat.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mp_threats/1
  # DELETE /mp_threats/1.xml
  def destroy
    @mp_threat = MpThreat.find(params[:id])
    @mp_threat.destroy

    respond_to do |format|
      format.html { redirect_to(mp_threats_url) }
      format.xml  { head :ok }
    end
  end
end
