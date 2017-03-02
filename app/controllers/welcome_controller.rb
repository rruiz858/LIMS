class WelcomeController < ApplicationController

  def index

    @total_bottles = Bottle.select(:barcode).uniq.where("qty_available_mg_ul >0").count

    @total_unique_compounds = Bottle.select(:compound_name).uniq.where("qty_available_mg_ul > 0").count

    if Activity.last.present?
    @last_updated = Activity.last.created_at.strftime("%m/%d/%Y %l:%m%p" )
    else
      @last_updated = "Never since there has not been an update yet, please submit a valid Comit for this to change"
    end

    if user_signed_in?
      redirect_to activities_path
    end
  end
end
