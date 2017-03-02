class ShipmentsActivitiesController < ApplicationController
  include ShipmentsActivitiesHelper
  def index
    @activities = ShipmentsActivity.order("created_at desc").paginate(:page => params[:page], :per_page => 15)
  end
end
