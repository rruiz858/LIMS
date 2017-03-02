require 'test_helper'
class SourceSubstanceTest < ActiveSupport::TestCase
  setup do
    @generic_substance = GenericSubstance.create(dsstox_substance_id: "DTXSID7020637",
                                                 casrn: "50-00-0")
    @chemical_list = ChemicalList.create
    @chemical_list2 = ChemicalList.create
    @chemical_list3 = chemical_lists(:two)
    @user = users(:superadmin).username
    @order = orders(:one)
    @order2 = orders(:three)
    @order_dsstox_chemical_list = OrderChemicalList.create(order_id: @order.id, chemical_list_id: @chemical_list.id)
    @order_dsstox_chemical_list2 = OrderChemicalList.create(order_id: @order2.id, chemical_list_id: @chemical_list2.id)
    @source_substance = SourceSubstance.create(fk_chemical_list_id: @chemical_list.id, dsstox_record_id: "HI", created_by: @user, updated_by:@user)
    @source_substance2 = SourceSubstance.create(fk_chemical_list_id: @chemical_list2.id, dsstox_record_id: "HI", created_by: @user, updated_by:@user)

    @source_substance_identifiers = SourceSubstanceIdentifier.create(fk_source_substance_id: @source_substance.id, identifier: "66-43-2", identifier_type: "CASRN")
    @source_substance3= source_substances(:two)
    @mapping = SourceGenericSubstance.create(fk_source_substance_id: @source_substance.id, fk_generic_substance_id: @generic_substance.id)
    @mapping2 = SourceGenericSubstance.create(fk_source_substance_id: @source_substance2.id, fk_generic_substance_id: @generic_substance.id)
    @coa_summary = CoaSummary.create(gsid: @generic_substance.id)
    @coa_summary2 = CoaSummary.create(gsid: @generic_substance.id)
    @bottle1 = Bottle.create(coa_summary_id: @coa_summary.id, concentration_mm: 20, qty_available_mg_ul: 1000, stripped_barcode: "TX87439")
    @bottle2 = Bottle.create(coa_summary_id: @coa_summary2.id, concentration_mm: 20, qty_available_mg_ul: 1000)
    @bottle3 = Bottle.create(coa_summary_id: @coa_summary.id, qty_available_mg_ul: 1000) #neat sample
    @bottle4 = Bottle.create(coa_summary_id: @coa_summary.id, qty_available_mg_ul: 100)
  end

  test "the truth" do
    assert true
  end

  test "Found Chemical Method " do
    @boolean =SourceSubstance.found_chemical(@source_substance)
    assert_equal @boolean, true
  end

  test "Chemical Available Method" do
    @boolean = SourceSubstance.chemical_available(@source_substance3)
    assert_equal @boolean, true
  end

  test "Same GSID Method" do
    @boolean = SourceSubstance.multiple_gsid(@source_substance3)
    assert_equal @boolean, true
  end

  test "Map to DSSTOX" do
    assert_difference('SourceGenericSubstance.count') do
      SourceSubstance.dsstox_mapping(@source_substance3)
    end
  end

  test "Get GSID class method" do
    @array = SourceSubstance.get_gsid("50-00-0", "DTXSID7020637", "TX87439", "TX7382326")
    assert @array.include? @generic_substance.id
  end

  test "test the list insert method" do
    assert_difference('SourceSubstance.count') do
      SourceSubstance.list_insert(@chemical_list, @chemical_list2, @user, @order)
    end
    assert_difference('SourceSubstanceIdentifier.count') do
      SourceSubstance.list_insert(@chemical_list, @chemical_list2, @user, @order)
    end
    assert_difference('SourceGenericSubstance.count') do
      SourceSubstance.list_insert(@chemical_list, @chemical_list2, @user, @order)
    end
  end

  test "check functionality of output of available/nonavailable/no hits query" do
    @chemical_list_test = chemical_lists(:four)
    @available_results= SourceSubstance.available(@chemical_list_test.id, @order.amount, @order.order_concentration.concentration)
    assert_match /"bottle_amount":700/, @available_results.to_json
    @not_available_results = SourceSubstance.not_available(@chemical_list_test.id, @order.amount, @order.order_concentration.concentration)
    @not_available_ss = source_substances(:six)
    assert_match /"id":#{@not_available_ss.id}/, @not_available_results.to_json
    @no_hits_results = SourceSubstance.no_hits(@chemical_list_test.id)
    @no_hits_ss = source_substances(:no_order_hits)
    assert_match /"id":#{@no_hits_ss.id}/, @no_hits_results.to_json
  end

end