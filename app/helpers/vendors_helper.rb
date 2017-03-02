module VendorsHelper
  def if_finalized?(vendor, agreement)
    if agreement.agreement_status.status == "Active" || agreement.agreement_status.status == "Revoked"
      link_to(manage_agreements_vendor_agreement_path(vendor.id, agreement.id), class: "btn btn-primary btn-xs", style: 'color:white', :disabled=> true) do
        ('Manage' + '' +content_tag(:span,"", class:"fa fa-pencil", disabled: true)).html_safe
      end
    else
      link_to(manage_agreements_vendor_agreement_path(vendor.id, agreement.id), class: "btn btn-primary btn-xs", style: 'color:white') do
        ('Manage' + '' +content_tag(:span,"", class:"fa fa-pencil")).html_safe
      end
    end
  end

  def if_active?(agreement)
    if agreement.active
      "Revoke Status"
    elsif agreement.agreement_status.status != "Revoked"
      "Update"
    else
      "Un-Revoke"
    end
  end

end
