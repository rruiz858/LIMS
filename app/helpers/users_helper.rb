module UsersHelper

  def admin?
    current_user && current_user.role.role_type == "admin"
  end

  def chemadmin?
    current_user &&  current_user.role.role_type == "chemadmin"
  end

  def chemcurator?
    current_user && current_user.role.role_type == "chemcurator"
  end

  def cor?
    @user ||= current_user
    @user && @user.role.role_type == "cor"
  end

  def postdoc?
    @user ||= current_user
    @user.role.role_type == "postdoc"
  end

  def contractadmin?
    current_user && current_user.role.role_type == "contractadmin"
  end

end