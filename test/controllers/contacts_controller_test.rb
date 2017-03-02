require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  setup do
    login_contract_admin
    @vendor1 = vendors(:vendor1)
    @contact = contacts(:one)
    @address = addresses(:fox_hunt)
    @address2 = addresses(:arapaho)
  end

  test "should get new" do
    get :new, vendor_id: @vendor1
    assert_response :success
  end

  test "should create contact" do
    assert_difference('Contact.count') do
      post :create, vendor_id: @vendor1, id: @contact,
           contact: {first_name: @contact.first_name, last_name: @contact.last_name, email: @contact.email,
                     title: @contact.title, department: @contact.department,
                     phone1: @contact.phone1, fax: @contact.fax, cell: @contact.cell,
                     other_details: @contact.other_details, vendor_id: @vendor1.id,
                     contact_type_id: @contact.contact_type.id,
                     address_attributes: {address1: @address.address1, address2: @address.address1,
                                          country: 'United State', state: 'PA',  city: 'Raleigh',
                                          zip: '27671', override_city: false}
                 }
    end
    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "should create address" do
    assert_difference('Address.count') do
      post :create, vendor_id: @vendor1, id: @contact,
           contact: {first_name: @contact.first_name, last_name: @contact.last_name, email: @contact.email,
                     title: @contact.title, department: @contact.department,
                     phone1: @contact.phone1, fax: @contact.fax, cell: @contact.cell,
                     other_details: @contact.other_details, vendor_id: @vendor1.id,
                     contact_type_id: @contact.contact_type.id,
                     address_attributes: {address1: @address.address1, address2: @address.address1,
                                          country: 'United State', state: 'PA',  city: 'Raleigh',
                                          zip: '27671', override_city: false}
           }
    end
    assert_redirected_to vendor_path(assigns(:vendor))
  end

  # test "should create address" do
  #   assert_difference('Address.count') do
  #     post :create, vendor_id: @vendor1, id: @contact,
  #          contact: {first_name: @contact.first_name, last_name: @contact.last_name, email: @contact.email,
  #                    title: @contact.title, department: @contact.department,
  #                    phone1: @contact.phone1, fax: @contact.fax, cell: @contact.cell,
  #                    other_details: @contact.other_details, vendor_id: @vendor1.id,
  #                    contact_type_id: @contact.contact_type.id,
  #                    address_attributes: {address1: @address.address1, address2: @address.address1,
  #                                         country: 'United State', state: 'PA',  city: 'Raleigh',
  #                                         zip: '27671', override_city: false}
  #          }
  #   end
  #   assert_redirected_to vendor_path(assigns(:vendor))
  # end






  test "should not create an address and ignore the city validation if the ignore city validation option is not selected" do
    assert_difference('Address.count', 0) do
      post :create, vendor_id: @vendor1, id: @contact,
           contact: {first_name: @contact.first_name, last_name: @contact.last_name, email: @contact.email,
                     title: @contact.title, department: @contact.department,
                     phone1: @contact.phone1, fax: @contact.fax, cell: @contact.cell,
                     other_details: @contact.other_details, vendor_id: @vendor1.id,
                     contact_type_id: @contact.contact_type.id,
                     address_attributes: {address1: @address.address1, address2: @address.address1,
                                          country: 'United State', state: 'PA',  city: '',
                                          zip: '27671', override_city: 'false'}
           }
    end
    assert_response :success,  "\nERROR - Response was a redirect thus a  new address record was created..BAD!"
  end


  test "should create an address and ignore the city validation if the ignore city valiadtion option is selected" do
    assert_difference('Address.count') do
      post :create, vendor_id: @vendor1, id: @contact,
           contact: {first_name: @contact.first_name, last_name: @contact.last_name, email: @contact.email,
                     title: @contact.title, department: @contact.department,
                     phone1: @contact.phone1, fax: @contact.fax, cell: @contact.cell,
                     other_details: @contact.other_details, vendor_id: @vendor1.id,
                     contact_type_id: @contact.contact_type.id,
                     address_attributes: {address1: @address.address1, address2: @address.address1,
                                          country: 'United State', state: 'PA',  city: '',
                                          zip: '27671', override_city: 'true'}
           }
    end
    assert_redirected_to vendor_path(assigns(:vendor)),  "\nERROR - Response was not a redirect thus a  new address was not created..BAD!"
  end

  test "should update contact and address" do
    patch :update, vendor_id: @vendor1, id: @contact,
          contact: {first_name: @contact.first_name, last_name: @contact.last_name, email: @contact.email,
                              title: @contact.title, department: @contact.department,
                              phone1: @contact.phone1, fax: @contact.fax, cell: @contact.cell,
                              other_details: @contact.other_details, vendor_id: @vendor1.id,
                              contact_type_id: @contact.contact_type.id,
                              address_attributes: {id: @address.id, address1: @address.address1, address2: @address.address1,
                                                   country: 'United State', state: 'PA',  city: 'Raleigh',
                                                   zip: '27671', override_city: false}
                  }
    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "should get edit" do
    get :edit, id: @contact, vendor_id: @vendor1
    assert_response :success
  end


  test "should destroy contact" do
    assert_difference('Contact.count', -1) do
      delete :destroy, id: @contact, vendor_id: @vendor1
    end
    assert_redirected_to vendor_path(assigns(:vendor))
  end

  test "test the state action and count of state options for the USA and does not return N/A as an option" do
    get :states, country: @address.country, format: :json
    @response_array = JSON.parse(@response.body)
    assert_response :success
    assert_equal 60, @response_array.count #there are 60 options for states/divisions for the United States
    assert_no_match /N\/A/, @response_array.to_s
  end

  test "test that the state action does return N/A in the array if the country is not the United States" do
    get :states, country: @address2.country, format: :json
    @response_array = JSON.parse(@response.body)
    assert_response :success
    assert_equal 14, @response_array.count # there are 13 options for states and one for N/A
    assert_match /N\/A/, @response_array.to_s
  end
end
