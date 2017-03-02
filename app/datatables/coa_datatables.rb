class CoaDatatables
  delegate :params, :h, :link_to, :button_to, :image_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Coa.count,
        iTotalDisplayRecords: coas.total_entries,
        aaData: data
    }
  end

  private

  def data

    coas.map do |coa|
      [   ERB::Util.h(coa.created_at),
          link_to(coa.filename, coa.file_url),
          ERB::Util.h(coa.user.username),
          ERB::Util.h(coa.barcode)
      ]
    end
  end

  def coas
    @coas ||= fetch_coas
  end

  def fetch_coas
    coas = Coa.order("#{sort_column} #{sort_direction}")
    coas = coas.page(page).per_page(per_page)
    if params[:sSearch].present?
      coas = coas.where("file_url like :search
                         or barcode like :search", search: "%#{params[:sSearch]}%")
    end
    coas
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 100
  end

  def sort_column
    columns = %w[created_at filename user_id barcode]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end


end
