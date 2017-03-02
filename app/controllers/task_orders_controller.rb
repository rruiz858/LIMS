class TaskOrdersController < ApplicationController
  include ViewVendorFilesHelper
  before_action :set_task_order, only: [ :edit, :update, :destroy]
  before_filter :authenticate_user!
  load_and_authorize_resource


  def new
    @agreement = Agreement.find(params[:agreement_id])
    @task_order = TaskOrder.new()
    @vendor = Vendor.find(params[:vendor_id])
    @button_text = "Create"
  end

  def edit
    @button_text = "Update"
  end

  def create
    @agreement = Agreement.find(params[:agreement_id])
    @vendor = Vendor.find(params[:vendor_id])
    @task_order.created_by = current_user.username
    create_rank(@agreement, @task_order)
    respond_to do |format|
      if @task_order.save
        path = directory_path
        tmp_string = task_order_directory(path, @task_order)
        format.html { redirect_to @vendor, success: 'Task was successfully added to agreement' }
        format.json { render :show, status: :created, location: @task_order }
        flash[:success] = "Task Order was successfully created \n #{tmp_string[1]}"
      else
        format.html { render :new }
        format.json { render json: @task_order.errors, status: :unprocessable_entity }
        task_errors
      end
    end
  end


  def update
    respond_to do |format|
      if @task_order.update(task_order_params)
        @agreement = Agreement.find(params[:agreement_id])
        format.html { redirect_to @vendor, success: 'Task Order was successfully updated.' }
        format.json
        flash[:success] = "Task Order was successfully updated"
      else
        format.html { render :edit }
        format.json { render json: @task_order.errors, status: :unprocessable_entity }
        task_errors
      end
    end
  end


  def destroy
    @task_order.destroy
    respond_to do |format|
      @agreement = Agreement.find(params[:agreement_id])
      format.html { redirect_to @agreement, success: 'Task Order was successfully destroyed.' }
      format.json { head :no_content }
      flash[:success] = "Task Order was successfully destroyed."
    end
  end

  private

  def create_rank(agreement, task_order)
    rank = agreement.task_orders.maximum("rank").to_i
    rank == 0 ? task_order.rank = 1 : task_order.rank = rank + 1
  end

  def set_task_order
    @task_order = TaskOrder.find(params[:id])
    @agreement = Agreement.find(params[:agreement_id])
    @vendor = Vendor.find(params[:vendor_id])
  end

  def task_errors
    error_str = " "
    @task_order.errors.full_messages.each do |message|
      error_str += message + "\n"
    end
    flash[:error] = "Validation errors #{ "\n" +error_str}"
  end

  def task_order_params
    params.require(:task_order).permit(:name, :description, :vendor_id, :agreement_id)
  end
end
