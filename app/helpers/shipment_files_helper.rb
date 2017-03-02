module ShipmentFilesHelper
  def vial_plate(boolean)
    boolean ? 'Vial' : 'Plate'
  end

  def mixture(boolean)
    '(Mixture)' if boolean
  end
  def if_legacy?(shipment_file)
    if (/^\Alegacy_/).match(shipment_file.original_filename)
     content_tag(:h6,"Legacy-Archived" ,:id => "shipment-file-#{shipment_file.id}")
    else
      link_to shipment_file.original_filename, shipment_file.file_url_url, class: 'link_to'
    end
  end

  def number_of_vials_plates(shipment_file)
    if shipment_file.vial
      shipment_file.vial_details.count
    else
      shipment_file.plate_details.count
    end
  end
end