class PlateDetailsController < ApplicationController
  include PlateDetailsHelper
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_action :set_plate_detail, only: [:show]
  before_action :set_shipment_file, only: [:unblinded, :blinded, :unblinded_vial, :blinded_vial, :check_availability]
  before_action :check_availability, only: [:unblinded, :blinded, :unblinded_vial, :blinded_vial]


  def unblinded #unblinded xlsx file
    plate_details = PlateDetail.where('Shipment_file_id = ?', "#{@shipment_file.id}")
    target_concentration = calculate_target_concentration(@shipment_file)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1.row(0).concat %w{
    Aliquot_Plate_Barcode
    Aliquot_Well_ID
    Aliquot_Concentration
    Target_Concentration
    Target_Concentration_Unit
    EPA_Sample_ID
    Aliquot_Volume
    Aliquot_Volume_Unit
    Aliquot_Solvent
    Aliquot_Date
    Bottle_ID
    DTXSID
    CASRN
    Preferred_Name
    }

    plate_details.order(:aliquot_plate_barcode).order(:aliquot_well_id).each_with_index do |plate_detail, i|
        sheet1.row(i+1).replace [plate_detail.aliquot_plate_barcode,
                                 plate_detail.aliquot_well_id,
                                 plate_detail.aliquot_conc,
                                 target_concentration,
                                 plate_detail.aliquot_conc_unit,
                                 plate_detail.blinded_sample_id,
                                 plate_detail.aliquot_volume,
                                 plate_detail.aliquot_volume_unit,
                                 plate_detail.aliquot_solvent,
                                 plate_detail.aliquot_date,
                                 plate_detail.bottle.barcode,
                                 plate_detail.bottle.generic_substance.dsstox_substance_id,
                                 plate_detail.bottle.generic_substance.casrn,
                                 plate_detail.bottle.generic_substance.preferred_name
                                ]
    end
     download_file(book, 'unblinded', 'plate_details')
  end


  def blinded #blinded xlsx file
    plate_details = PlateDetail.where('Shipment_file_id = ?', "#{@shipment_file.id}")
    target_concentration = calculate_target_concentration(@shipment_file)
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1.row(0).concat %w{
    Aliquot_Plate_Barcode
    Aliquot_Well_ID
    Target_Concentration
    Target_Concentration_Unit
    EPA_Sample_ID
    Aliquot_Volume
    Aliquot_Volume_Unit
    Aliquot_Solvent
    Aliquot_Date
    }
    plate_details.order(:aliquot_plate_barcode).order(:aliquot_well_id).each_with_index do |plate_detail, i|
      sheet1.row(i+1).replace [plate_detail.aliquot_plate_barcode,
                               plate_detail.aliquot_well_id,
                               target_concentration,
                               plate_detail.aliquot_conc_unit,
                               plate_detail.blinded_sample_id,
                               plate_detail.aliquot_volume,
                               plate_detail.aliquot_volume_unit,
                               plate_detail.aliquot_solvent,
                               plate_detail.aliquot_date]
    end
    download_file(book, 'blinded', 'plate_details')
  end

  def blinded_vial #blinded xls file
    vial_details = VialDetail.where('Shipment_file_id = ?', "#{@shipment_file.id}")
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1.row(0).concat %w{
    Aliquot_Vial_Barcode
    Aliquot_Well_ID
    Amount
    Amount_Unit
    EPA_Sample_ID
    Aliquot_Date
    }
    vial_details.order(:aliquot_vial_barcode).each_with_index do |vial_detail, i|
      sheet1.row(i+1).replace [vial_detail.aliquot_vial_barcode,
                               vial_detail.aliquot_well_id,
                               vial_detail.aliquot_amount,
                               vial_detail.aliquot_amount_unit,
                               vial_detail.blinded_sample_id,
                               vial_detail.aliquot_date]
    end
    download_file(book, 'blinded', 'vial_details')
  end

  def unblinded_vial #unblinded xls file
    vial_details = VialDetail.where('Shipment_file_id = ?', "#{@shipment_file.id}")
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1.row(0).concat %w{
    Aliquot_Vial_Barcode
    Aliquot_Well_ID
    Amount
    Amount_Unit
    EPA_Sample_ID
    Aliquot_Date
    Bottle_ID
    DTXSID
    CASRN
    Preferred_Name
    }
    vial_details.order(:aliquot_vial_barcode).each_with_index do |vial_detail, i|
        sheet1.row(i+1).replace [vial_detail.aliquot_vial_barcode,
                                 vial_detail.aliquot_well_id,
                                 vial_detail.aliquot_amount,
                                 vial_detail.aliquot_amount_unit,
                                 vial_detail.blinded_sample_id,
                                 vial_detail.aliquot_date,
                                 vial_detail.bottle.stripped_barcode,
                                 vial_detail.bottle.generic_substance.dsstox_substance_id,
                                 vial_detail.bottle.generic_substance.casrn,
                                 vial_detail.bottle.generic_substance.preferred_name]
    end
    download_file(book, 'unblinded', 'vial_details')
  end


  def show
    @coa_summary = @plate_detail.bottle.coa_summary
    @generic_substance = @coa_summary.generic_substance
  end

  def show_vial
    @vial_detail = VialDetail.find(params[:vial_detail_id])
    @coa_summary = @vial_detail.bottle.coa_summary
    @generic_substance = @coa_summary.generic_substance
  end

  private

  def download_file(book, type, kind)
    evotec_shipment_number = @shipment_file.evotech_shipment_num
    vendor = vendor_name(@shipment_file.vendor)
    number_of_details = @shipment_file.send(kind).count
    date = Time.now.strftime('%Y%m%d')
    type == 'unblinded' ? filename = "EPA_#{evotec_shipment_number}_#{vendor}_#{number_of_details}_#{date}_key.xls" : filename = "EPA_#{evotec_shipment_number}_#{vendor}_#{number_of_details}_#{date}.xls"
    spreadsheet = StringIO.new
    book.write spreadsheet
    send_data spreadsheet.string, :filename => filename, :type => "application/vnd.ms-excel"
  end

  def check_availability
    if @shipment_file.plate_details.blank? && @shipment_file.vial_details.blank?
     redirect_to shipment_file_path(@shipment_file)
     flash[:notice] ="This action is not available at this time"
    end
  end

  def vendor_name(vendor)
    vendor.name.blank? ? 'NoNAme' : vendor.name.gsub(/\s/,'')
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_plate_detail
    @plate_detail = PlateDetail.find(params[:id])
  end

  def set_shipment_file
    @shipment_file = ShipmentFile.find(params[:shipment_file_id])
  end

  def calculate_target_concentration(shipment_file)
    @order = Order.where(:id =>  [shipment_file.order_number, shipment_file.order_id])
    if @order.blank?
      temp_array = Array.new
      concentrations = shipment_file.plate_details
      concentrations.each{ |i| temp_array.push(i[:aliquot_conc])}
      median(temp_array)  #method created in the plate_detail_helper that calculates the target_concentration
    else
      @order.first.order_concentration.concentration
    end
  end

end
