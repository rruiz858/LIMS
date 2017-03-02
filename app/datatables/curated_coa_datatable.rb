class CuratedCoaDatatable
  include CoaSummariesHelper
  delegate :params, :h, :link_to, :button_to, :coa_summary_path,:bottle_path, :content_tag, :raw, :image_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: CoaSummary.count,
        iTotalDisplayRecords: coa_summaries.total_entries,
        aaData: data
    }
  end

  private

  def data
    coa_summaries.map do |coa_summary|
      [
          ERB::Util.h(coa_summary.id),
          ERB::Util.h(coa_summary.gsid),
          "<a href= #{bottle_path(coa_summary.direct_bottle_match)} data-remote='true'>" \
          "<button class='btn btn-default btn-xs'>"+ "#{coa_summary.bottle_barcode}"\
          "<span class='fa fa-list-ul'></span></button></a>",
          ERB::Util.h(coa_summary.coa_chemical_name),
          ERB::Util.h(coa_summary.coa_casrn),
          ERB::Util.h(coa_summary.coa_purity_percentage),
          ERB::Util.h(coa_summary.coa_methods),
          ERB::Util.h(coa_summary.coa_test_date),
          ERB::Util.h(coa_summary.coa_expiration_date),
          ERB::Util.h(coa_summary.updated_at),
          pdf_exsists?(coa_summary.coa) ? generate_link(coa_summary.coa, 'COA') : 'No File',
          pdf_exsists?(coa_summary.msd) ? generate_link(coa_summary.msd, 'MSDS') : 'No File',
          "<a href= #{coa_summary_path(coa_summary.id)} data-remote='true'>" \
          "<button class='btn btn-primary btn-xs'>Show</button></a>"
      ]
    end
  end

  def coa_summaries
    @coa_summaries ||= fetch_coa_summaries
  end

  def fetch_coa_summaries
    coa_summaries = CoaSummary.order("#{sort_column} #{sort_direction}").where("gsid IS NOT NULL")
    coa_summaries = coa_summaries.page(page).per_page(per_page)
    if params[:sSearch].present?
      coa_summaries = coa_summaries.where("
                                gsid like :search
                                or bottle_barcode like :search
                                or coa_chemical_name like :search
                                or coa_casrn like :search
                                or coa_purity_percentage like :search
                                or coa_methods like :search
                                or coa_test_date like :search
                                or coa_expiration_date like :search
                                or updated_at like :search ", search: "%#{params[:sSearch]}%")
    end
    coa_summaries
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 100
  end

  def sort_column
    columns = %w[id gsid bottle_barcode coa_chemical_name coa_casrn coa_purity_percentage coa_methods coa_test_date coa_expiration_date updated_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end


end
