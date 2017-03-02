class MsdsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:create]
  before_action :set_msd, only: [:destroy]


  # GET /msds/1
  # GET /msds/1.json
  # GET /msds/new
  def index
    respond_to do |format|
      format.html
      format.json { render json: MsdsDatatables.new(view_context) }
    end
  end
  def new
    @msds_upload = MsdsUpload.new
  end

  # GET /msds/1/edit

  def create
    @msds = MsdsUpload.new(msds_uploads_params)
    @msds.save
    error_str = " "
    success_str = " "
    @msds.msds_pdfs.each do |a|
      @msd = Msd.new(filename: a, file_url: a, user_id: current_user.id, )
      @file_name = a.filename.downcase
      string = @file_name.to_s
      if !(/_msds.pdf\z/.match(string)).nil?
        @barcode = string.chomp('_msds.pdf')
      elsif !(/_coa_msds.pdf\z/.match(string)).nil?
        @barcode = string.chmop('_coa_msds.pdf')
      elsif @barcode = string
      end

      @coa_summary = CoaSummary.find_by_bottle_barcode("#{@barcode}")
      unless @coa_summary.nil?
        @msd.coa_summary_id = @coa_summary.id
        @msd.barcode = @barcode
        success_str += a.filename+ "\n"
      end
      unless @msd.save
        error_str += a.filename + "\n"
      end
    end
    total_messages = error_str + success_str
    unless total_messages.blank?
      redirect_to coas_path
      unless error_str.blank?
        flash[:error] = 'The following files where not linked:' + error_str
      end
      unless success_str.blank?
        flash[:success]= 'The following MSDS where imported:' + success_str
      end
    else
      flash[:error] = 'Must select a MSDS file'
      redirect_to :back
    end
  end


  # DELETE /msds/1
  # DELETE /msds/1.json
  def destroy
    @msd.destroy
    respond_to do |format|
      format.html { redirect_to coas_url, notice: 'Msd was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def file_format(file)
    mime_types = ["application/pdf"]
    mime_types.include? file_url.content_type
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_msd
      @msd = Msd.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
  def msds_uploads_params
    params.require(:msd).permit({msds_pdfs: []})
  end
end
