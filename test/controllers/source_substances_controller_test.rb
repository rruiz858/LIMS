require 'test_helper'
class SourceSubstancesControllerTest < ActionController::TestCase
  setup do
    login_chemadmin
    @user = users(:superadmin)
    @generic_substance = GenericSubstance.create(dsstox_substance_id: "DTXSID7020637",
                                                       casrn: "50-00-0")
    @generic_substance2 = GenericSubstance.create(dsstox_substance_id: "DTXSID2024088",
                                                       casrn: "60-00-0")
    @chemical_list = ChemicalList.create
    @order = orders(:one)
    @order_dsstox_chemical_list = OrderChemicalList.create(order_id: @order.id, chemical_list_id: @chemical_list.id)
    @source_substance = SourceSubstance.create(fk_chemical_list_id: @chemical_list.id, dsstox_record_id: "HI", created_by: @user.username, updated_by:@user.username )
    @source_substance1 = SourceSubstance.create(fk_chemical_list_id: @chemical_list.id, dsstox_record_id: "HI", created_by: @user.username, updated_by:@user.username)
    @source_substance2 = SourceSubstance.create(fk_chemical_list_id: @chemical_list.id, dsstox_record_id: "HI", created_by: @user.username, updated_by:@user.username)
    @source_substance3 = SourceSubstance.create(fk_chemical_list_id: @chemical_list.id, dsstox_record_id: "HI", created_by: @user.username, updated_by:@user.username)
    @mapping = SourceGenericSubstance.create(fk_source_substance_id: @source_substance.id, fk_generic_substance_id: @generic_substance.id)
    @mapping2 = SourceGenericSubstance.create(fk_source_substance_id: @source_substance3.id, fk_generic_substance_id: @generic_substance2.id)
    @control = Control.create(source_substance_id: @source_substance.id, order_id: @order.id, controls: false)
    @source_substance4 = source_substances(:two)
  end

  test "Should create source substance" do
    assert_difference('SourceSubstance.count', 4) do
      post :create,  {add_list: "Add to Chemical List", new_chemical_list_id: @chemical_list.id, fk_chemical_list_id: @chemical_list.id, dsstox_record_id: "test", casrn: "casrn" , name: "Test", bottle_id: "bottle" , dtxid: "dtxid", sample_id: "sample_id", updated_by: "Raymond", created_by: "Raymond", format: :js, :source_substance => {:control_attributes => {control: false}}}
    end
  end

  test "Should create  new control record" do
    assert_difference('Control.count') do
      @order5= orders(:five)
      post :update_control, id: @source_substance4.id, order: @order5.id, state: true, format: :json
      assert_response :success
      assert_match 'CNTRL1', Control.last.identifier
      assert_equal @source_substance4.id, Control.last.source_substance_id
    end
  end

  test "should update control" do
    @order4= orders(:four)
    post :update_control, id: @source_substance.id, order: @order4.id, state: true, format: :json
    assert_response :success
    assert_match 'CNTRL2', Control.order(:updated_at => 'desc').first.identifier
  end

  test "should obtain the correct the gsid" do
     @request.env['HTTP_REFERER'] = 'http://test.com/sessions/source_substance'
     post :update_gsid, id: @source_substance4,  change_gsid: "#{ @generic_substance.id}", gsid: "#{@generic_substance.id}"
     get :show_gsids, id: @source_substance4
     assert_response :success
  end

  test "should test the standard_replicates action " do
    @chemical_list = chemical_lists(:eleven)
    @order = orders(:eleven)
    assert_difference('Control.count', 7) do
      assert_difference('SourceSubstance.count', 7) do
        assert_difference('SourceSubstanceIdentifier.count', 13) do
          get :standard_replicates, order_id: @order.id, format: :json
        end
      end
    end
  end

end