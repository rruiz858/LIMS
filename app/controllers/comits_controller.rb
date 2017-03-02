class ComitsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_action :set_comit, only: [:show, :edit, :update]
  include TestEnvironment
  include OpenExcel


  # GET /comits
  # GET /comits.json
  def index
    @bottles_no_coa = Bottle.where("qty_available_mg >0 || qty_available_ul >0").where("coa_summary_id IS NULL").count
    @comits = Comit.all.includes(:user)
  end

  def show
  end
  # GET /comits/1
  # GET /comits/1.json

  # GET /comits/new
  def new
    @comit = Comit.new
  end

  # GET /comits/1/edit
  def edit
  end

  # POST /comits
  # POST /comits.json
  def create
    @comit = Comit.new(comit_params)
    @comit.user = current_user
    @comit.filename = @comit.file_url.filename
    unless @comit.filename.nil?
      @comit.file_app_name = @comit.filename[11, 30] # This column save the original filename
    end
    if @comit.save
      if test_environment
        ProcessComitJob.new @comit
      else
        Delayed::Job.enqueue(ProcessComitJob.new(@comit), :run_at => 0.seconds.from_now, job_id: @comit.id, job_type: "Comit")
      end
      track_activity @comit
      redirect_to comits_path
      flash[:success] = "Comit was added to the queue"
      mutiple_sheets(@comit.file_url.path)
      additional_headers(@comit.file_url.path)
    else
      error_str = " "
      for msg in @comit.errors.messages[:file_url].each
        error_str += msg.to_s + "\n"
      end
      flash[:error] = error_str
      redirect_to new_comit_path
    end
  end



  # PATCH/PUT /comits/1
  # PATCH/PUT /comits/1.json
  def update
    respond_to do |format|
      if @comit.update(comit_params)
        track_activity @comit
        format.html { redirect_to @comit, notice: 'Comit was successfully updated.' }
        format.json { render :show, status: :ok, location: @comit }
      else
        format.html { render :edit }
        format.json { render json: @comit.errors, status: :unprocessable_entity }
      end
    end
  end

  def comit_error
    @comit= Comit.find(params[:comit_id])
    @error_a = @comit.file_error.error_a.split(/\r?\n/)
    @error_b = @comit.file_error.error_b.split(/\r?\n/)
    @error_a_array = @error_a.join(', ')
    @error_b_array = @error_b.join(', ')
    @error_a_count = @error_a.count
    @error_b_count = @error_b.count
  end
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_comit
    @comit = Comit.find(params[:id])
  end


  def  comit_params
    params.fetch(:comit, {}).permit(:user_id, :filename, :file_app_name, :file_url)
  end
end
