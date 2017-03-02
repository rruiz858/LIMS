class OrderCommentsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  before_filter :check_order_status
  before_filter :load_order, only: [:all_comments, :create]
  include OrdersHelper

  def all_comments
    respond_to do |format|
      format.js { render 'order_comments/all_comments', :object => @order }
    end
  end

  def create
    @comment = @order.order_comments.new(body: comment_params[:body])
    @comment.created_by = current_user.username
    if @comment.save
      @message = @comment.body
    else
      @errors = ''
      @comment.errors.full_messages.each do |message|
        @errors += message
      end
      @order.reload
    end
    respond_to do |format|
      format.js { render 'order_comments/create' }
    end
  end


  private

  def comment_params
    params.permit(:body, :order_id)
  end

  def load_order
    @order = Order.find(params[:order_id])
  end

  def check_order_status #private method checks to see if the parent order is in_review or if it's in progress
    load_order
    redirect_to_back(orders_path) unless in_progress? || in_review?
  end

end
