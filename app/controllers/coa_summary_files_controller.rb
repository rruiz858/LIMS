class CoaSummaryFilesController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_action :set_coa_summary_file, only: [:show, :destroy]
  include OpenExcel
  include TestEnvironment


  # GET /coa_summary_files/1
  # GET /coa_summary_files/1.json
  def show
  end

  # GET /coa_summary_files/new
  def new
    @coa_summary_file = CoaSummaryFile.new
  end

  # GET /coa_summary_files/1/edit
  # def edit
  # end

  # POST /coa_summary_files
  # POST /coa_summary_files.json
  def create
    @coa_summary_file = CoaSummaryFile.new(coa_summary_file_params)
    @coa_summary_file.user = current_user
    @coa_summary_file.filename = @coa_summary_file.file_url.filename
    respond_to do |format|
      if @coa_summary_file.save
        if test_environment
          ProcessCoaSummary.new @coa_summary_file
        else
          Delayed::Job.enqueue(ProcessCoaSummary.new(@coa_summary_file), :run_at => 0.seconds.from_now, job_id: @coa_summary_file.id, job_type: "CoaSummaryFile")
        end
        format.html { redirect_to coa_summaries_url, success: 'Coa summary file was successfully created.' }
        format.json { render :show, status: :created, location: coa_summary_files_url }
        flash[:success] = "COA Summary File was added to the queue"
        mutiple_sheets(@coa_summary_file.file_url.path)
      else
        error_str = " "
        for msg in @coa_summary_file.errors.messages[:file_url].each
          error_str += msg.to_s + "\n"
        end
        flash[:error] = error_str
        format.html { redirect_to new_coa_summary_file_path }
      end
    end
  end

  def destroy
    @coa_summary_file.destroy
    respond_to do |format|
      format.html { redirect_to coa_summaries_url, notice: 'Coa summary file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def coa_summary_file_error
    @coa_summary_file= CoaSummaryFile.find(params[:coa_summary_file_id])
    @error_a = @coa_summary_file.file_error.error_a.split(/\r?\n/)
    @error_b = @coa_summary_file.file_error.error_b.split(/\r?\n/)
    @error_c = @coa_summary_file.file_error.error_c.split(/\r?\n/)
    @error_a_array = @error_a.join(', ')
    @error_b_array = @error_b.join(', ')
    @error_c_array = @error_c.join(', ')
    @error_a_count = @error_a.count
    @error_b_count = @error_b.count
    @error_c_count = @error_c.count
    respond_to do |format|
      format.html
      format.js
    end
  end
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_coa_summary_file
      @coa_summary_file = CoaSummaryFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def coa_summary_file_params
      params.fetch(:coa_summary_file, {}).permit(:user_id, :filename, :file_url, :file_kilobytes)
    end


end