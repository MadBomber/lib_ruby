class MpTewaFactorsController < ApplicationController
  # GET /mp_tewa_factors
  # GET /mp_tewa_factors.xml
  def index
    @mp_tewa_factors = MpTewaFactor.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mp_tewa_factors }
    end
  end

  # GET /mp_tewa_factors/1
  # GET /mp_tewa_factors/1.xml
  def show
    @mp_tewa_factor = MpTewaFactor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mp_tewa_factor }
    end
  end

  # GET /mp_tewa_factors/new
  # GET /mp_tewa_factors/new.xml
  def new
    @mp_tewa_factor = MpTewaFactor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mp_tewa_factor }
    end
  end

  # GET /mp_tewa_factors/1/edit
  def edit
    @mp_tewa_factor = MpTewaFactor.find(params[:id])
  end

  # POST /mp_tewa_factors
  # POST /mp_tewa_factors.xml
  def create
    @mp_tewa_factor = MpTewaFactor.new(params[:mp_tewa_factor])

    respond_to do |format|
      if @mp_tewa_factor.save
        flash[:notice] = 'MpTewaFactor was successfully created.'
        format.html { redirect_to(@mp_tewa_factor) }
        format.xml  { render :xml => @mp_tewa_factor, :status => :created, :location => @mp_tewa_factor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mp_tewa_factor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mp_tewa_factors/1
  # PUT /mp_tewa_factors/1.xml
  def update
    @mp_tewa_factor = MpTewaFactor.find(params[:id])

    respond_to do |format|
      if @mp_tewa_factor.update_attributes(params[:mp_tewa_factor])
        flash[:notice] = 'MpTewaFactor was successfully updated.'
        format.html { redirect_to(@mp_tewa_factor) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mp_tewa_factor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mp_tewa_factors/1
  # DELETE /mp_tewa_factors/1.xml
  def destroy
    @mp_tewa_factor = MpTewaFactor.find(params[:id])
    @mp_tewa_factor.destroy

    respond_to do |format|
      format.html { redirect_to(mp_tewa_factors_url) }
      format.xml  { head :ok }
    end
  end
end
