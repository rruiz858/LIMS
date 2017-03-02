class MsdsDatatables
  delegate :params, :h, :link_to, :button_to, :image_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: Msd.count,
        iTotalDisplayRecords: msds.total_entries,
        aaData: data
    }
  end

  private

  def data

    msds.map do |msd|
      [   ERB::Util.h(msd.created_at),
          link_to(msd.filename, msd.file_url),
          ERB::Util.h(msd.user.username),
          ERB::Util.h(msd.barcode)
      ]
    end
  end

  def msds
    @msds ||= fetch_msds
  end

  def fetch_msds
    msds = Msd.order("#{sort_column} #{sort_direction}")
    msds = msds.page(page).per_page(per_page)
    if params[:sSearch].present?
      msds = msds.where("file_url like :search
                         or barcode like :search", search: "%#{params[:sSearch]}%")
    end
    msds
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
