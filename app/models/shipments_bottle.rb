class ShipmentsBottle < ActiveRecord::Base
  belongs_to :shipment_file
  belongs_to :bottle
  validate :validate_barcodes

  def validate_barcodes
    unless Bottle.where(stripped_barcode: "#{self.barcode}").exists?
      errors.add(:Barcode, " '#{self.barcode }' is not in the Bottle inventory")
    end
  end


  def insert_details(bottle_array, shipment_file)
    concentration_relation = shipment_file.order_concentration
    concentration = concentration_relation[:concentration]
    concentration_unit = concentration_relation[:unit]
    @error_row_feeder = ''
    @error_string = ''
    @success_string = 'All barcodes where found'
    ShipmentsBottle.transaction do
      begin

        @well_array = Array.new(0)
        plate_detail = shipment_file.plate_detail
        case
          when (plate_detail == "96" && maximum_capacity(bottle_array.count, 96, shipment_file ))
            define_wells(12, "H", shipment_file)
          when (plate_detail == "384" && maximum_capacity(bottle_array.count, 384, shipment_file ))
            define_wells(24, "P", shipment_file)
          else
            model = ShipmentsBottle.new
            model.errors.add(:barcode, "Plate has reached maximum capacity")
            @error_string << model.errors.messages[:barcode].first
            raise ActiveRecord::Rollback
        end
        bottle_array.zip(@well_array).each do |bottle, well_id|
          ShipmentsBottle.create!(shipment_file_id: shipment_file[:id],
                                 plate_barcode: bottle,
                                 concentration: concentration,
                                 concentration_unit: concentration_unit,
                                 amount: shipment_file[:amount],
                                 amount_unit: shipment_file[:amount_unit],
                                 barcode: bottle,
                                 well_id: well_id)
        end
      rescue Exception => @error_row_feeder
        @error_string << @error_row_feeder.to_s
      end
      if @error_string.blank?
        return true, @success_string
      else
        return false, @error_string
      end
    end
  end

  def define_wells(max_integer, max_letter, shipment_file)
    letter_array = ('A'.."#{max_letter}").to_a
    number_array = Array.new(max_integer) {|i| (i+1)}
    combined_array = Array.new(0)
    letter_array.product(number_array) {|i| combined_array.push(i.join)}
    last_slot = ShipmentsBottle.find_by_sql("SELECT well_id FROM shipments_bottles as sb where sb.shipment_file_id = #{shipment_file.id}  ORDER BY sb.id DESC LIMIT 1 ;").first.try(:well_id)
    if last_slot.blank?  #if no wells have yet been assinged to shipment, The first well will be A1
      @well_array = combined_array
    else    #if there are wells that have been assigned then, logic will find the last well and begin from assigning from there.
      @well_array  = combined_array.select {|e| e=="#{last_slot}" .. false ? true : false }[1..-1]
    end
  end

  def maximum_capacity(new_count, plate_count, shipment_file)
   current_count = ShipmentsBottle.find_by_sql("SELECT count(*) as count FROM shipments_bottles as sb where sb.shipment_file_id = #{shipment_file.id};").first.try(:count)
   if current_count + new_count < plate_count
    true
   else
    false
   end
  end

  def finalize(shipment_file)
    @shipment_id = shipment_file.id
    connection = ActiveRecord::Base.connection
    new_plate_barcode = plate_barcode
    connection.execute("INSERT INTO plate_details (blinded_sample_id,aliquot_plate_barcode, aliquot_well_id, aliquot_conc, aliquot_conc_unit, source_barcode, shipment_file_id, created_at, updated_at)
        SELECT CONCAT('#{new_plate_barcode}',sb.well_id), '#{new_plate_barcode}', sb.well_id, sb.concentration, sb.concentration_unit, sb.barcode,sb.shipment_file_id, now(), now()
        FROM shipments_bottles as sb
        WHERE sb.shipment_file_id = #{@shipment_id};")
    connection.execute("UPDATE plate_details AS pd
        INNER JOIN bottles AS b
        ON pd.source_barcode = b.stripped_barcode
        set pd.bottle_id = b.id
        WHERE pd.shipment_file_id = #{@shipment_id};")
    connection.execute("DELETE sb FROM shipments_bottles AS sb
        WHERE sb.shipment_file_id = #{@shipment_id}")
  end

  def plate_barcode
    @query = PlateDetail.where("aliquot_plate_barcode LIKE ?", "EP0%").order("id DESC").first
    if @query.blank?
      plate_barcode ="EP000001"
    else
      query_string = @query.aliquot_plate_barcode.gsub(/EP/, '')
      query_integer = query_string.to_i + 1
      plate_barcode ="EP00000"+"#{query_integer}"
    end
  end
end

