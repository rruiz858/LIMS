class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update]
  before_action :admin_permissions
  before_filter :authenticate_user!
  load_and_authorize_resource

  def show
  end

  def edit
  end

  def new
    @query = Query.new
  end

  def create
    @query = Query.new(query_params)
    @query.created_by = current_user.username
    respond_to do |format|
      if @query.save
        format.html { redirect_to @query }
        flash[:success] = "Query was successfully added"
      else
        format.html { render :new }
        format.json { render json: @query.errors, status: :unprocessable_entity }
        query_errors
      end
    end
  end

  def update
    respond_to do |format|
      @query.updated_by = current_user.username
      if @query.update(query_params)
        format.html { redirect_to @query, success: 'Query was successfully updated.' }
      else
        format.html { render :edit }
        format.json { render json: @query.errors, status: :unprocessable_entity }
        query_errors
      end
    end
  end


  def update_all
    @queries = Query.all
    user = current_user.username
    results = Hash.new(0)
    begin
      @queries.each { |query| query.updated_by = user; query.save }
    rescue => @error_string
      if @error_string.present?
        Rails.logger.error @error_string
      end
    end
    temp_string = '<table class= "table-bordered table-condensed table-hover table-striped" "id=queryTable" cellspacing="0" width="100%"">
                     <thead>
                     <tr>
                         <th>label</th>
                         <th>count</th>'
    if can? :manage, Query
      temp_string += '<th> </th>'
    end
    temp_string += '</tr> </thead>'
    if !@error_string.blank?
      results[:valid] = false
      results[:error_string] = @error_string
      temp_string +=
          '<tbody>' +
              '<tr>' +
              '<td>' + '-' + '</td>' +
              '<td>' + '-' + '</td>'
              if can? :manage, Query
                temp_string +=   '<td>' + '-' '</td>'
              end
              '</tr>' +
          '</tbody>'
    else
      @updated_queries = Query.select("SQL_CACHE id, name, label, complete_query, count").all
      results[:valid] = true
      temp_string += '<tbody>'
      @updated_queries.each do |query|
        temp_string +=
            '<tr>' +
                "<td>" + "<span class='fa fa-info-circle fa-lg fontAwesomeToggle'" +
                "data-toggle='popover' data-content= " + "'"+ query.complete_query.gsub("'", '') + "'"+
                "data-trigger='hover' data-placement='bottom'></span>" + " #{query.label}" +
                '</td>' +
                '<td>' + "#{query.count}" + '</td>'
        if can? :manage, Query
          temp_string += '<td>' + "<a href= #{edit_query_path(query.id)}>" +
                         "<button class='btn btn-primary btn-xs'> <span class='fa fa-pencil-square-o'></span> Edit</button></a>" +
                         '</td>'
        end
            '</tr>'
      end
      temp_string += '</tbody>'
    end
    temp_string += '</table>'
    results[:html] = temp_string
    respond_to do |format|
      format.json { render json: results }
    end
  end

  private

  def query_errors
    error_str = " "
    @query.errors.full_messages.each do |message|
      error_str += message + "\n"
    end
    Rails.logger.error error_str
    flash.now[:error] = "Validation errors #{ "\n" +error_str}"
  end

  def set_query
    @query = Query.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def query_params
    params.require(:query).permit(:name, :label, :description, :created_by, :sql, :conditions)
  end
end