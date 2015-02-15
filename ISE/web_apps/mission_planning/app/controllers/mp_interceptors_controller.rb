class MpInterceptorsController < ApplicationController
  # GET /mp_interceptors
  # GET /mp_interceptors.xml
  def index
    @mp_interceptors = MpInterceptor.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mp_interceptors }
    end
  end

  # GET /mp_interceptors/1
  # GET /mp_interceptors/1.xml
  def show
    @mp_interceptor = MpInterceptor.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mp_interceptor }
    end
  end

  # GET /mp_interceptors/new
  # GET /mp_interceptors/new.xml
  def new
    @mp_interceptor = MpInterceptor.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mp_interceptor }
    end
  end

  # GET /mp_interceptors/1/edit
  def edit
    @mp_interceptor = MpInterceptor.find(params[:id])
  end

  # POST /mp_interceptors
  # POST /mp_interceptors.xml
  def create
    @mp_interceptor = MpInterceptor.new(params[:mp_interceptor])

    respond_to do |format|
      if @mp_interceptor.save
        flash[:notice] = 'MpInterceptor was successfully created.'
        format.html { redirect_to(@mp_interceptor) }
        format.xml  { render :xml => @mp_interceptor, :status => :created, :location => @mp_interceptor }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mp_interceptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mp_interceptors/1
  # PUT /mp_interceptors/1.xml
  def update
    @mp_interceptor = MpInterceptor.find(params[:id])

    respond_to do |format|
      if @mp_interceptor.update_attributes(params[:mp_interceptor])
        flash[:notice] = 'MpInterceptor was successfully updated.'
        format.html { redirect_to(@mp_interceptor) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mp_interceptor.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mp_interceptors/1
  # DELETE /mp_interceptors/1.xml
  def destroy
    @mp_interceptor = MpInterceptor.find(params[:id])
    @mp_interceptor.destroy

    respond_to do |format|
      format.html { redirect_to(mp_interceptors_url) }
      format.xml  { head :ok }
    end
  end
end
