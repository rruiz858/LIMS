require 'test_helper'

class OrderPlateDetailTest < ActiveSupport::TestCase
  setup do
  @generic_substance = GenericSubstance.create(dsstox_substance_id: "DTXSID7020637",
                                                     casrn: "50-00-0")
  @chemical_list = ChemicalList.create
  @order = orders(:one)
  @user = users(:cor)
  @order_dsstox_chemical_list = OrderChemicalList.create(order_id: @order.id, chemical_list_id: @chemical_list.id)
  @source_substance = SourceSubstance.create(fk_chemical_list_id: @chemical_list.id, dsstox_record_id: "HI", created_by: @user, updated_by:@user)
  @order_plate_detail = order_plate_details(:one)
  end


  test "Should test the plate_count class method" do
   count =  OrderPlateDetail.plate_count( @order_plate_detail.plate_type.label, @chemical_list.source_substances.count)
   assert_equal 1, count.to_i
  end




end
