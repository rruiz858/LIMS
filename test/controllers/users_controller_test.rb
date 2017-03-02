require 'test_helper'
class UsersControllerTest < ActionController::TestCase
  setup do
   @user = users(:superadmin)
   @cor1 = users(:cor)
   @cor2 = users(:cor2)
   @role = roles(:one)
   @user2 = User.create(:email => "testemail@gmial.com", role: @role)
   @post_doc = users(:postdoc)
   @post_doc_role = roles(:five)
  end


  test "should allow authorized user to go to the new user page" do
     login_superadmin
     get :new
     assert_template :new
   end

  test "should get edit" do
    login_superadmin
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    login_superadmin
    patch :update, id: @user, user: { f_name: "Raymond", l_name: "Ruiz", password: "llamas",
                                       email: "rruiz@ncsu.edu", username: "rruizvev",
                                       role_id: @role}
    assert_redirected_to user_path(assigns(:user))
  end

  test "should update postdoc's associations" do
    login_superadmin
    assert_difference('MentorPostdoc.count', 1 , "Should only create one record since postdoc already has cor1 as a cor" ) do
    patch :update, id: @post_doc, user: { f_name: "postdoc", l_name: "postdoc", password: "llamas",
                                      email: "postdoc@test.com", username: "rruizvev",
                                      role_id: @post_doc_role} ,cor_ids: ["#{@cor1.id}", "#{@cor2.id}"]
    end
    assert_redirected_to user_path(assigns(:user))
  end

  test "should test the select cor input to make sure that the full name of the cors are being displayed correctly" do
    login_superadmin
    get :new
    assert_template :new
    assert_select "select#cor-options", {:count => 1, :label => /cor-cor/}
    assert_select "select#cor-options [value]" , /.+/
  end
  test "should not allow non superadmin users to visit the new users page" do
    login_chemadmin
    @request.env['HTTP_REFERER'] = 'http://chemtrack/activities/'
    get :new
    assert_response :redirect
  end

  test "should create user" do
    login_superadmin
    assert_difference('User.count') do
      post :create, user: { f_name: "Raymond", l_name: "Ruiz", password: "llamas",
                              email: "rruiz@ncsu.edu", username: "rruizvev",
                              role_id: @role}
    end
    assert_redirected_to users_path
  end

  test "should create new associations between User and MentorPorstDocs " do
    login_superadmin
    assert_difference('MentorPostdoc.count', 2) do
        post :create, user: { f_name: "Raymond", l_name: "Ruiz", password: "llamas",
                              email: "rruiz@ncsu.edu", username: "rruizvev",
                              role_id: @post_doc_role}, cor_ids: ["#{@cor1.id}", "#{@cor2.id}"]
      end
      assert_redirected_to users_path
    end

  test "should destroy User" do
    login_superadmin
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end
    assert_redirected_to users_path
  end

  test "should destroy MentorPostDoc associations from postdocs if a postdoc user is destroyed" do
    login_superadmin
    assert_difference ['User.count','MentorPostdoc.count'],-1,"The correct relationships where not destroyed when destroying a postdoc" do
      delete :destroy, id: @post_doc
    end
    assert_redirected_to users_path
  end

end
