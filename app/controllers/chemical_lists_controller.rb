class ChemicalListsController < ApplicationController
  include ApplicationHelper
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_action :set_chemical_list, only: [:show]
  before_action :set_order, only: [:show]
  before_action :order_owner, only: [:show]
  include OrdersHelper

  def show
    if in_progress? || chemadmin?
      available_lists
      @chemical_list = ChemicalList.find(params[:id])
      @order_amount = @order.amount
      @order_concentration = @order.order_concentration.concentration
      @available = SourceSubstance.available_and_controls(@chemical_list.id,@order_amount, @order_concentration, @order.id)
      @not_available = SourceSubstance.not_available(@chemical_list.id, @order_amount, @order_concentration)
      @duplicates = SourceSubstance.duplicates(@chemical_list.id)
      @no_hits = SourceSubstance.no_hits(@chemical_list.id)
      @results_hash = {"available" => @available, "not_available" => @not_available, "duplicates" => @duplicates, "no_hits" => @no_hits}
    else
      redirect_to :back
      flash[:notice] = 'You are unable to make changes at this time'
    end
  end

  private
  def set_chemical_list
    @chemical_list = ChemicalList.find(params[:id])
  end

  def available_lists
    if admin? || chemadmin?
      @lists = ChemicalList.all
    elsif cor? || postdoc?
      @lists =  ChemicalList.where("list_abbreviation LIKE 'TOXCST%' OR (list_accessibility = 'PRIVATE' && created_by = '#{@order.user.username}')")
    end
  end
  def set_order
    @order = Order.find(@chemical_list.order_chemical_list.order_id)
  end

  def chemical_list_params
    params.require(:chemical_list).permit(:plate_detail)
  end
end