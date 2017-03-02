class CoasController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource except: [:create]
  before_action :set_coa, only: [:destroy]

  # GET /coas
  # GET /coas.json
  def index
    respond_to do |format|
      format.html
      format.json { render json: CoaDatatables.new(view_context) }
    end
  end


  # GET /coas/new
  def new
    @coa = CoaUpload.new
  end

  # POST /coas
  # POST /coas.json
  def create
    @coas = CoaUpload.new(coa_uploads_params)
    @coas.save
    error_str = " "
    success_str = " "
    @coas.coa_pdfs.each do |a|
      @coa = Coa.new(filename: a, file_url: a, user_id: current_user.id)
      @file_name = a.filename.downcase
      string = @file_name.to_s
      if !(/_coa.pdf\z/.match(string)).nil?
        @barcode = string.tr('_coa.pdf', '')
      elsif !(/_coa_msds.pdf\z/.match(string)).nil?
        @barcode = string.tr('_coa_msds.pdf', '')
      elsif @barcode = string
      end

      @coa_summary = CoaSummary.find_by_bottle_barcode("#{@barcode}")
      unless @coa_summary.nil?
        @coa.coa_summary_id = @coa_summary.id
        @coa.barcode = @barcode
        success_str += a.filename+ "\n"
      end
      unless @coa.save
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
        flash[:success]= 'The following COAS where imported:' + success_str
      end
    else
      flash[:error] = 'Must select a COA file'
      redirect_to :back
    end
  end

  # PATCH/PUT /coas/1
  # PATCH/PUT /coas/1.json
  def update
    respond_to do |format|
      if @coa.update(coa_params)
        format.html { redirect_to @coa, notice: 'Coa was successfully updated.' }
        format.json { render :show, status: :ok, location: @coa }
      else
        format.html { render :edit }
        format.json { render json: @coa.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /coas/1
  # DELETE /coas/1.json
  def destroy
    @coa.destroy
    respond_to do |format|
      format.html { redirect_to coas_url, notice: 'Coa was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_coa
    @coa = Coa.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def coa_uploads_params
    params.require(:coa).permit({coa_pdfs: []})
  end
end
