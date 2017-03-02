module CoaSummariesHelper

  def get_pdf(pdfs, coa_summary)
    html = '<ul>'
    pdfs.each do |pdf|
      record = coa_summary.send(pdf.to_sym)
      if pdf_exsists?(record)
        html<< '<li class='<< 'pdfs-class' <<'>'
        html << generate_link(record, pdf)
        html << '</li>'
      end
    end
    html << '</ul>'
    html.html_safe
  end

  def pdf_exsists?(coa_msds)
    coa_msds.nil? ? false : true
  end

  def generate_link(coa_msds, pdf)
    link_to coa_msds.file_url, target: :_blank, class:"coa-msds-pdf"  do
      raw(content_tag(coa_msds.file_url, pdf))
    end
  end

end

