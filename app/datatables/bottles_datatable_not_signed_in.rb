
class BottlesDatatableNotSignedIn
  delegate :params, :h, :link_to,:bottle_path, :button_to, :image_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Bottle.count,
        iTotalDisplayRecords: bottles.total_entries,
        aaData: data
    }
  end

  private

  def data

    bottles.map do |bottle|
      [
          "<a href= #{bottle_path(bottle.id)} data-remote='true'>" \
          "<button class='btn btn-default btn-xs'>"+ "#{bottle.stripped_barcode} "\
          "<span class='fa fa-list-ul'></span></button></a>",
          ERB::Util.h(bottle.compound_name),
          ERB::Util.h(bottle.cas),
          ERB::Util.h(bottle.qty_available_mg_ul),
          ERB::Util.h(bottle.units),
          ERB::Util.h(bottle.vendor),
          ERB::Util.h(bottle.sam),
          ERB::Util.h(bottle.cpd),

      ]
    end
  end

  def bottles
    @bottles ||= fetch_bottles
  end

  def fetch_bottles
    bottles = Bottle.order("#{sort_column} #{sort_direction}").where("qty_available_mg_ul >0").where("coa_summary_id IS NOT NULL")
    bottles = bottles.page(page).per_page(per_page)
    if params[:sSearch].present?
      bottles = bottles.where(" barcode_parent like :search
                                  or barcode like :search
                                  or compound_name like :search
                                  or cas like :search
                                  or qty_available_mg_ul like :search
                                  or units like :search
                                  or vendor like :search
                                  or sam like :search
                                  or cpd like :search", search: "%#{params[:sSearch]}%")
    end
    bottles
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 100
  end

  def sort_column
    columns = %w[barcode_parent barcode compound_name cas qty_available_mg_ul units lot_number vendor sam cpd ]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end
end