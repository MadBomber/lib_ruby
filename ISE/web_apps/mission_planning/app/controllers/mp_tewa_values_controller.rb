class MpTewaValuesController < ApplicationController
  # GET /mp_tewa_values
  # GET /mp_tewa_values.xml
  def index
    @mp_tewa_values = MpTewaValue.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mp_tewa_values }
    end
  end

  # GET /mp_tewa_values/1
  # GET /mp_tewa_values/1.xml
  def show
    @mp_tewa_value = MpTewaValue.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mp_tewa_value }
    end
  end

  # GET /mp_tewa_values/new
  # GET /mp_tewa_values/new.xml
  def new
    @mp_tewa_value = MpTewaValue.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mp_tewa_value }
    end
  end

  # GET /mp_tewa_values/1/edit
  def edit
    @mp_tewa_value = MpTewaValue.find(params[:id])
  end

  # POST /mp_tewa_values
  # POST /mp_tewa_values.xml
  def create
    @mp_tewa_value = MpTewaValue.new(params[:mp_tewa_value])

    respond_to do |format|
      if @mp_tewa_value.save
        flash[:notice] = 'MpTewaValue was successfully created.'
        format.html { redirect_to(@mp_tewa_value) }
        format.xml  { render :xml => @mp_tewa_value, :status => :created, :location => @mp_tewa_value }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mp_tewa_value.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mp_tewa_values/1
  # PUT /mp_tewa_values/1.xml
  def update
    @mp_tewa_value = MpTewaValue.find(params[:id])

    respond_to do |format|
      if @mp_tewa_value.update_attributes(params[:mp_tewa_value])
        flash[:notice] = 'MpTewaValue was successfully updated.'
        format.html { redirect_to(@mp_tewa_value) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mp_tewa_value.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mp_tewa_values/1
  # DELETE /mp_tewa_values/1.xml
  def destroy
    @mp_tewa_value = MpTewaValue.find(params[:id])
    @mp_tewa_value.destroy

    respond_to do |format|
      format.html { redirect_to(mp_tewa_values_url) }
      format.xml  { head :ok }
    end
  end
end
