require 'test_helper'

class BottlesControllerTest < ActionController::TestCase

  setup do
    login_chemadmin
    @bottle = bottles(:one)
    @bottle2 = bottles(:two)
    @bottle15 = bottles(:fifteen)
    @external_bottle = bottles(:twentythree)
    @coa_summary = coa_summaries(:one)
    @synonym_mv = synonym_mvs(:one)
    @synonym_mv_bottle = synonym_mvs(:eight)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:bottles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should show table with an id of bottles " do
    get :index
    assert_response :success
    assert_select 'table#bottles' do
      assert_select 'tr#content'
    end
  end

  test "should contain the index bottle information in a json format" do
    get :index, format: :json do
      assert_match /TX016151.*TX77788/, @response.body #sees if the json response does infact contain bottles from the bottle fixture file
      assert_equal "constant", defined?(BottlesDatatable)
    end
    assert_response :success
  end

  test "should create an external bottle and the stripped_barcode should be incremented from the last external barcode" do
    assert_difference('Bottle.count',) do
      post :create, bottle: {cas: @bottle.cas,
                             compound_name: @bottle.compound_name,
                             qty_available_mg_ul: @bottle.qty_available_mg,
                             lot_number: @bottle.lot_number,
                             cid: @bottle.cid,
                             cpd: @bottle.cpd,
                             comment: @bottle.comment}
    end
    bottle =  Bottle.last
    assert_equal bottle.stripped_barcode, "EX000011"
    assert_redirected_to bottles_path
  end

  test "should show bottle" do
    xhr :get, :show, id: @bottle, format: :js
    assert_response :success
  end

  test "should get edit view and show a checkbox" do
    xhr :get, :edit, {id: @bottle, format: :js} do
      @response.content_type = 'text/html'
      assert_select 'input[type=checkbox][checked=checked]'
    end
    assert_response :success

  end

  test "should have an unchecked checkbox if can_plate attribute is set to false" do
    xhr :get, :edit, {id: @bottle2, format: :js} do
      @response.content_type = 'text/html'
      assert_select 'input[type=checkbox][checked=checked]', false
    end
    assert_response :success
  end

  test "should update non-external bottle" do
    xhr :get, :edit, {id: @bottle, format: :js}
    assert_response :success
    assert_template 'bottles/edit'
    xhr :patch, :update, id: @bottle, bottle: {can_plate: "false", comment: "This is a new comment for the bottle ", format: :js}
    assert_template 'bottles/_tab_contents'
    assert_response :success
  end
  test "should update external bottle" do
    xhr :get, :edit_external_bottle, {id: @bottle, format: :js}
    assert_response :success
    assert_template 'bottles/edit_external_bottle'
    xhr :patch, :edit_external_bottle, id: @external_bottle, update_external: 'true',
                                               bottle: {cas: '67-43-2',
                                                        cid: '54654',
                                                        compound_name: 'badbad',
                                                        lot_number: '789',
                                                        cpd: '8594',
                                                        qty_available_mg_ul: 78,
                                                        can_plate: "false",
                                                        comment: "This is a new comment for the bottle ",
                                                        format: :js}
    assert_template 'bottles/_tab_contents'
    assert_response :success
  end


  test "should destroy bottle" do
    assert_difference('Bottle.count', -1) do
      delete :destroy, id: @bottle
    end

    assert_redirected_to bottles_path
  end

  test "search method when search term is in bottle table" do
    get :single_results, {search: "Aspirin"}
    assert_response :success
    assert_select 'p', {text:  "'Aspirin' was found in the DssTox database. No bottles associated with 'Aspirin'"}
  end

  test "search method when search term is in generic substance but not in the bottle table" do
    get :single_results, {search: "26148-68-5"}
    assert_response :success
    assert_select 'p', {text:"'26148-68-5' was found in the DssTox database. No bottles associated with '26148-68-5'"}
  end

  test "search method when term does not exist" do
    get :single_results, {search: "Llamas"}
    assert_response :success
    assert_select 'p', {text: "Found 1 bottles for 'Llamas'."}
  end

  test "should search with barcode in single results" do
    get :single_results, {search: "TX0THISGROSS"}
    assert_response :success
    assert_select 'p', {text: "Found 1 bottles for 'TX0THISGROSS'."}
    assert_select 'td.resultsBarcode', {count: 1, text: 'TX0THISGROSS', message: 'Searched barcode was not found in single chemical search'}
  end

  test "should not search via EPA Sample ID if user is not signed in" do
    session.clear #this is done to log out
    get :single_results, {search: "EPA_Sample_ID_1"}
    assert_response :success
    assert_select 'p', {count: 1, text: "'EPA_Sample_ID_1' was not found in the DssTox database.", message: 'Unauthorized access of single results via sample id' }
    assert_select 'td.resultsBarcode', {count: 0, message: 'a results was found when there should have been none!'}
  end


  test "should search via EPA Sample ID if user signed in and should only return one result" do
    #chemadmin is logged in in setup
    get :single_results, {search: "EPA_Sample_ID_1"}
    assert_response :success
    assert_select 'p', {count: 1, text: "Found 1 bottles for 'EPA_Sample_ID_1'.", message: 'sample id did not correct function in single results' }
    assert_select 'td.resultsBarcode', {count: 1, message: 'No bottles were found for this sample id'}
  end

 test "should get the multiple results view" do
   get :multiple_results
   assert_response :success
   assert_select "form"
   assert_select 'h1', { count:1, text: 'Multiple Chemical Search'},
       'Wrong tittle or more than one title element'
 end

  test "should get multiple results and should test the text of gsid found" do
    get :multiple_results, {find_results: "Search Chemicals", chemical_search: "Aspirin\r\n69-69-699\r\nChemicalX\n"}
    assert_response :success
    assert_select 'tr', { count: 4 }, "Attributes were not added to html table"
    assert_select "td#bottle-#{@synonym_mv.generic_substance.id }", {text: "#{@synonym_mv.generic_substance.id}"}
    assert_select "td#20mM-#{@synonym_mv.generic_substance.id }", {text: "LOW"}
    assert_select "td#100mM-#{@synonym_mv.generic_substance.id }", {text: "NONE"}
    assert_select "td#neat-#{@synonym_mv.generic_substance.id }", {text: "NONE"}
    assert_select "td#20mM-#{@synonym_mv_bottle.generic_substance.id }", {text: "NONE"}
    assert_select "td#100mM-#{@synonym_mv_bottle.generic_substance.id }", {text: "NONE"}
    assert_select "td#neat-#{@synonym_mv_bottle.generic_substance.id }", {text: "HIGH"}
  end

  test "should test the solution option in multiple results " do
    get :multiple_results, {find_results: "Search Chemicals", chemical_search: "Aspirin\r\n69-69-699\r\n", min_conc:'0' , max_conc:'24' , amount:'30'}
    assert_response :success
    assert_select 'tr', { count: 3 }, "Attributes were not added to html table"
    assert_select "td#20mM-#{@synonym_mv.generic_substance.id }", {text: "LOW"}
    assert_select "td#100mM-#{@synonym_mv.generic_substance.id }", {text: "NONE"}
    assert_select "td#neat-#{@synonym_mv.generic_substance.id }", {text: "NONE"}
    assert_select "td#totalCount-#{@synonym_mv.generic_substance.id }", {text: "3"}
  end


  test "should test the correct output of chemical export when the ALL selection in advanced filter is selected " do
    data_params = "[{\"id\":null, \"gsid\":281110143, \"identifier\":\"ChemicalX\", \"searched_term\":\"ChemicalX\", \"coa_id\":507103779, \"kind\":\"Preferred Name\", \"casrn\":\"70-00-73\", \"total_count\":0, \"preferred_name\":\"somethingmoredangerous\", \"bottle_count\":2, \"neat\":\"HIGH\", \"100mM\":\"NONE\", \"20mM\":\"NONE\", \"amount\":11, \"count\":2},
                   {\"id\":null, \"gsid\":374648174, \"searched_term\":\"01000010\", \"identifier\":\"01000010\", \"kind\":\" ChemTrack Barcode\", \"total_count\":0, \"casrn\":\"69-69-699\", \"preferred_name\":\"NAME1\", \"bottle_count\":3, \"neat\":\"NONE\", \"100mM\":\"NONE\", \"20mM\":\"LOW\", \"amount\":150, \"count\":3}]"
   user_params = {"all" => 'true'}
   path = Rails.root.join('public','chemical_export.xls').to_s
   post :export_chemicals, {data: data_params, params: user_params, format: :json} do
   assert_response :success
   assert_match path, response.body
   end
   get :open_bottle_file, {path: path}
   assert_match /chemical_export/, response.headers.to_s
   assert_match /application\/vnd.ms-excel/, response.headers.to_s
   filename = ('test/fixtures/files/multiple_search/output_chemical_export'+Time.now.strftime('_%Y-%m-%d_%H_%M_%S'+'.xls')).to_s
   expected_file = fixture_file_upload('files/multiple_search/all_search.xls', 'application/vnd.ms-excel')
   File.open(filename, 'w:ASCII-8BIT') {|f| f.puts response.body }
   output_book = Spreadsheet.open(filename)
   expected_book = Spreadsheet.open(expected_file)
   output1 = []
   output2 = []
   output_sheet1 = output_book.worksheet(0)
   output_sheet2 = output_book.worksheet(1)
   output_sheet1.each do |row|
    output1.push row
   end
   output_sheet2.each do |row|
     output2.push row
   end
   expected1 =[]
   expected2 = []
   expected_sheet1 = expected_book.worksheet(0)
   expected_sheet2 = expected_book.worksheet(1)
   expected_sheet1.each do |row|
     expected1.push row
   end
   expected_sheet2.each do |row|
     expected2.push row
   end
   output1.each_with_index do |row, index|
     row.each_with_index do |element, inner_index|
       assert_match expected1[index][inner_index].to_s, element.to_s, 'wrong output for '+row[1]+' '+output1[0][inner_index]
     end
   end
   output2.each_with_index do |row, index|
     row.each_with_index do |element, inner_index|
       assert_match expected2[index][inner_index].to_s, element.to_s, 'wrong output for '+row[1]+' '+output2[0][inner_index]
     end
   end
   assert_equal expected1.count, output1.count, "Output from created file does not match expected"
   assert_equal expected2.count, output2.count, "Output from second spreadsheet does not match expected"
   File.delete(filename)
  end


  test "should test the correct output of chemical export when the NEAT selection in advanced filter is selected " do
    data_params = "[{\"id\":null, \"gsid\":281110143, \"identifier\":\"ChemicalX\", \"searched_term\":\"ChemicalX\", \"coa_id\":507103779, \"kind\":\"Preferred Name\", \"casrn\":\"70-00-73\", \"total_count\":0, \"preferred_name\":\"somethingmoredangerous\", \"bottle_count\":2, \"neat\":\"HIGH\", \"100mM\":\"NONE\", \"20mM\":\"NONE\", \"amount\":11, \"count\":2},
                   {\"id\":null, \"gsid\":374648174, \"searched_term\":\"01000010\", \"identifier\":\"01000010\", \"kind\":\" ChemTrack Barcode\", \"total_count\":0, \"casrn\":\"69-69-699\", \"preferred_name\":\"NAME1\", \"bottle_count\":3, \"neat\":\"NONE\", \"100mM\":\"NONE\", \"20mM\":\"LOW\", \"amount\":150, \"count\":3}]"
    neat_params = {:neat=>true, :min_conc=>"0", :max_conc=>"0", :amount=>"4", :units=>"('mg')", :unit=>"mg", :type=>"neat"}
    path = Rails.root.join('public','chemical_export.xls').to_s
    post :export_chemicals, {data: data_params, params: neat_params, format: :json} do
      assert_response :success
      assert_match path, @response.body
    end
    get :open_bottle_file, {path: path}
    assert_match /chemical_export/, response.headers.to_s
    assert_match /application\/vnd.ms-excel/, response.headers.to_s
    filename = ('test/fixtures/files/multiple_search/output_neat_chemical_export'+Time.now.strftime('_%Y-%m-%d_%H_%M_%S'+'.xls')).to_s
    expected_file = fixture_file_upload('files/multiple_search/neat_expected_chemical_export.xls', 'application/vnd.ms-excel')
    File.open(filename, 'w:ASCII-8BIT') {|f| f.puts response.body }
    output_book = Spreadsheet.open(filename)
    expected_book = Spreadsheet.open(expected_file)
    output1 = []
    output2 = []
    output_sheet1 = output_book.worksheet(0)
    output_sheet2 = output_book.worksheet(1)
    output_sheet1.each do |row|
      output1.push row
    end
    output_sheet2.each do |row|
      output2.push row
    end
    expected1 =[]
    expected2 = []
    expected_sheet1 = expected_book.worksheet(0)
    expected_sheet2 = expected_book.worksheet(1)
    expected_sheet1.each do |row|
      expected1.push row
    end
    expected_sheet2.each do |row|
      expected2.push row
    end
    output1.each_with_index do |row, index|
      row.each_with_index do |element, inner_index|
        assert_match expected1[index][inner_index].to_s, element.to_s, 'wrong output for '+row[1]+' '+output1[0][inner_index]
      end
    end
    output2.each_with_index do |row, index|
      row.each_with_index do |element, inner_index|
        assert_match expected2[index][inner_index].to_s, element.to_s, 'wrong output for '+row[1]+' '+output2[0][inner_index]
      end
    end
    assert_equal expected1.count, output1.count, "Output from created file does not match expected"
    assert_equal expected2.count, output2.count, "Output from second spreadsheet does not match expected"
    File.delete(filename)
  end

  test "should test the show bottle results action " do
    get :multiple_results, {find_results: "Search Chemicals", chemical_search: "ChemicalX"}
    user_params = {"neat"=>"true", "min_conc"=>"0", "max_conc"=>"0", "amount"=>"4", "units"=>"('mg')", "unit"=>"mg", "type"=>"neat"}
    get :show_bottle_results, {gsid: "#{@synonym_mv_bottle.generic_substance.id}", params: user_params,  format: :json } do
      assert_select "td#barcode-#{@bottle.stripped_barcode }", {text: "#{@bottle.stripped_barcode}"},
                    "Bottle was not found corretly by the search bottle query method"
      assert_select 'tr', { count: 3 }
    end
    assert_response :success
  end

end
