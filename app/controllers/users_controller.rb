class UsersController < ApplicationController
  load_and_authorize_resource
  before_filter :authenticate_user!

  def index
    @users = User.all
  end

  def new
    @user_roletype = Role.find_by_role_type("admin")
    @user = User.new
  end

  def show
   available_cors
  end

  def edit
    @user_roletype = Role.find_by_role_type("admin")
    available_cors
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if postdoc?
        cors = params[:cor_ids]
        cor_post_doc_relationship(cors)
      end
      flash[:success] = "Successfully created User"
      redirect_to users_path
    else
      redirect_to new_user_path
      flash[:error] = "#{@user.errors.messages.to_s.scan(/"([^"]*)"/)}"
    end
  end

  def update
    begin
      @errors = ""
      ActiveRecord::Base.transaction do
        if @user.update(user_params)
        edit_relationships(params[:cor_ids]) if postdoc?
        else
          @errors << user_errors.to_s
        end
      end
    rescue => e
      @errors << e.to_s
      Rails.logger.error @errors
    end
    respond_to do |format|
      if @errors.blank?
        format.html { redirect_to @user}
        format.json { render :show, status: :ok, location: @user }
        flash[:success] = "User was successfully updated!"
      else
        available_cors
        @user_roletype = Role.find_by_role_type("admin")
        format.html { render :edit }
        flash[:error] = "#{@errors}"
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


  private

  def full_name
    "#{f_name} #{l_name}"
  end

  def cors_params
    params.permit(:cors_id)
  end

  def user_params
    params.require(:user).permit(:f_name, :l_name, :email, :role_id, :username)
  end

  def available_cors
    if postdoc?
      @cors = User.select("users.username, users.f_name, users.l_name, users.id").where(id: @user.cors.map { |i| i.cor_id })
      @cor_array = @cors.map { |i| i.id }
    end
  end

  def cor_post_doc_relationship(cors)
    cors.each do |cor_id|
      MentorPostdoc.create(cor_id: cor_id.to_i, post_doc_id: @user.id)
    end
  end

  def edit_relationships(cors_id)
    if @user.cors.blank?
      cor_post_doc_relationship(cors_id)
    else
      available_cors  #populates @cor_array object
      current_cors = @cor_array.map(&:to_i)
      new_cors_params = cors_id.map(&:to_i)  #array of a new cor params
      deletes = cor_array_diffences(current_cors, new_cors_params)
      creates = cor_array_diffences(new_cors_params, current_cors)
      cor_post_doc_relationship(creates) unless creates.blank?
      delete_relationships(deletes) unless deletes.blank?
    end
  end

  def cor_array_diffences(first, second)
    first - second
  end

  def delete_relationships(cors)
     MentorPostdoc.where("cor_id IN (?) AND post_doc_id = ?", cors, @user.id).destroy_all
  end

  def user_errors
    error_str = " "
    @user.errors.full_messages.each do |message|
      error_str += message + "\n"
    end
  end

end



