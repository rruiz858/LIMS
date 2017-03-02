module MultipleSearch
  extend ActiveSupport::Concern
  include DsstoxSchema
  include BottleSearch

  Availability = Struct.new(:neat, :twentyul, :onehundredul)
  Parameters = Struct.new(:max, :min, :min_conc_default, :max_conc_default, :kind, :unit, :amount, :min_conc, :max_conc)

  def multi_chemical_search(terms, options)
    query_terms = terms.to_s.gsub(/\[|\]/, '').gsub(/"(.*?)"/, '("\1")')
    @dsstox_schema = database_initialization #method from Dsstox Schema concern to insert into the correct version of DssTox
    config = Rails.configuration.database_configuration
    chemtrack_database = config[Rails.env]["database"] #returns a hash to make sure it's using the current version of ChemTrack
    connection = ActiveRecord::Base.connection #utilizes the current connection
    if test_database_connection
      begin
        unique_temp_table = "#{chemtrack_database}.temp_table_#{Time.now.to_i}"
        connection.execute("CREATE TEMPORARY TABLE #{unique_temp_table}(
                          ID int NOT NULL AUTO_INCREMENT,
                          temp_identifier VARCHAR(255),
                          PRIMARY KEY(ID),
                          INDEX (temp_identifier));")
        connection.execute("ALTER TABLE #{unique_temp_table} CONVERT TO CHARACTER SET utf8 COLLATE utf8_unicode_ci;")
        connection.execute("INSERT INTO #{unique_temp_table}(temp_identifier) VALUES #{query_terms};")
        bottle_query = CoaSummary.find_by_sql("SELECT b2.searched_term, coa.gsid as gsid, coa.id,
                          b2.identifier, ' ChemTrack Barcode' as kind, COUNT(distinct b3.id) as total_count,
                          gs.casrn, gs.preferred_name
                          FROM  #{chemtrack_database}.coa_summaries as coa
                          INNER JOIN(
                          SELECT b.coa_summary_id , temp.id, temp.temp_identifier AS searched_term, temp.temp_identifier AS identifier from bottles as b
                          inner join  #{unique_temp_table} AS temp
                          on temp.temp_identifier = b.stripped_barcode
                          )b2
                          on b2.coa_summary_id = coa.id
                          INNER JOIN #{@dsstox_schema[:gs]} as gs
                          ON coa.gsid = gs.id
                          INNER JOIN #{chemtrack_database}.coa_summaries as coas2
                          ON coas2.gsid = gs.id
                          INNER JOIN #{chemtrack_database}.bottles as b3
                          ON b3.coa_summary_id = coas2.id
                          GROUP BY b2.identifier, gs.id
                           ;")

        synonym_mv_query = CoaSummary.find_by_sql("SELECT   smv.identifier as identifier ,temp.id, temp.temp_identifier AS searched_term, smv.fk_generic_substance_id as gsid, coa.id as coa_id,
                          smv.synonym_type as kind, gs.casrn as casrn, (Select count(b2.id) from bottles as b2
                          INNER JOIN coa_summaries as coa2 on b2.coa_summary_id = coa2.id
                          where coa2.gsid = smv.fk_generic_substance_id) as total_count,
                          gs.preferred_name as preferred_name
                          FROM #{unique_temp_table} AS temp
                          LEFT OUTER JOIN #{@dsstox_schema[:sm]} AS smv
                          ON temp.temp_identifier = smv.identifier
                          LEFT OUTER JOIN #{@dsstox_schema[:gs]} AS gs
                          ON smv.fk_generic_substance_id = gs.id
                          LEFT OUTER JOIN #{chemtrack_database}.coa_summaries AS coa
                          ON gs.id = coa.gsid
                          LEFT OUTER JOIN #{chemtrack_database}.bottles AS b
                          ON coa.id = b.coa_summary_id
                          GROUP BY temp.id, smv.identifier  HAVING (min(smv.rank) or
                                                   temp.id > 0 );")
        intersection = bottle_query.map { |i| i.attributes['searched_term'] } & synonym_mv_query.map { |i| i.attributes['searched_term'] }
        delete_duplicate_barcodes = synonym_mv_query.delete_if { |h| intersection.include? h.attributes['searched_term'] }
        bottles= bottle_query.select { |h| intersection.include? h.attributes['searched_term'] }
        @results = delete_duplicate_barcodes + bottles
        @results_array = @results.as_json.each{|i| i['bottle_count'] = i['total_count']}
        @gsid_array = @results.map(&:'gsid') #{return an array of gsids}
        @all = options[:all]
        query_values(options) #generates instances
        @amounts = find_amounts(options)
        @query_results = all_search(@amounts[:neat], @amounts[:twenty], @amounts[:onehundred])
        return true, 'success', @query_results
      rescue Mysql2::Error => e #check for errors in database
        return false, e.error, @query_results
      ensure
        connection.execute("DROP TABLE #{unique_temp_table};")
      end
    else
      return false, 'DssTox services are currently down', @query_results
    end
  end


  def test_database_connection
    begin
      GenericSubstance.first
    rescue
      return false
    end
  end

  def query_values(options)
    @max_amount = {neat: 5, twenty: 500, onehundred: 100}
    @min_conc = {neat: 0, twenty: 0, onehundred: 24}
    @max_conc =  {neat: 0, twenty: 24, onehundred: 104}
    @kind = %w(neat 20mM 100mM)
    @unit = %w(ul mg)
    @user_min_conc = options[:min_conc]
    @user_max_conc = options[:max_conc]
    @user_amount = options[:amount]
  end

  def find_amounts(options)
    if options[:neat]
      neat_params = Parameters.new(@max_amount[:neat], 0, @min_conc[:neat], @max_conc[:neat], @kind[0], @unit[1], @user_amount, 0, 0)
      twenty_params = Parameters.new(@max_amount[:twenty], 0, @min_conc[:twenty], @max_conc[:twenty], @kind[1], @unit[0], 0, nil, nil)
      onehundred_params = Parameters.new(@max_amount[:onehundred], 0, @min_conc[:onehundred], @max_conc[:onehundred], @kind[2], @unit[0], 0, nil, nil)
    elsif options[:solution]
      neat_params = Parameters.new(@max_amount[:neat], 0, @min_conc[:neat], @max_conc[:neat], @kind[0], @unit[0], @user_amount, nil, nil)
      twenty_params = Parameters.new(@max_amount[:twenty], 0, @min_conc[:twenty], @max_conc[:twenty], @kind[1], @unit[0], @user_amount, @user_min_conc, @user_max_conc)
      onehundred_params = Parameters.new(@max_amount[:onehundred], 0, @min_conc[:onehundred], @max_conc[:onehundred], @kind[2], @unit[0], @user_amount, @user_min_conc, @user_max_conc)
    else
      neat_params = Parameters.new( @max_amount[:neat], 0, @min_conc[:neat], @max_conc[:neat], @kind[0], @unit[1], 0, 0, 0)
      twenty_params = Parameters.new(@max_amount[:twenty], 0, @min_conc[:twenty], @max_conc[:twenty], @kind[1], @unit[0], 0, 0, 24)
      onehundred_params = Parameters.new(@max_amount[:onehundred], 0, @min_conc[:onehundred], @max_conc[:onehundred], @kind[2], @unit[0], 0, 24, 100)
    end
     {neat: neat_params, twenty: twenty_params, onehundred: onehundred_params}
  end

  def all_search(neat_params, twenty_params, onehundred_params)
    neat = neat_availability_query(@gsid_array, neat_params)
    twenty= solution_availability_query(@gsid_array, twenty_params)
    onehundred = solution_availability_query(@gsid_array, onehundred_params)
    array_builder(Availability.new(neat, twenty, onehundred), @results_array)
  end

  def solution_availability_query(gsid_array, params)
    results= Bottle.find_by_sql(["SELECT sum(b.qty_available_mg_ul) as amount, coa.gsid as gsid, COUNT(b.id) as count,
                                  CASE
                                  WHEN sum(b.qty_available_mg_ul) > ? THEN 'HIGH'
                                  WHEN sum(b.qty_available_mg_ul) between ? AND ?  THEN 'LOW'
                                  ELSE 'NONE'
                                  END as ?
                                  FROM
                                  bottles as b
                                  INNER JOIN coa_summaries as coa
                                  ON
                                  b.coa_summary_id = coa.id
                                  WHERE (coa.gsid IN (?) )
                                  AND ((ifnull(b.concentration_mm,0) between ? AND ?) AND (ifnull(b.concentration_mm,0) between ? AND ?))
                                  AND (b.units = ?)
                                  AND (b.qty_available_mg_ul > ?)
                                  GROUP BY gsid;",
                                  params.max, params.min, params.max,
                                  params.kind, gsid_array, params.min_conc_default,
                                  params.max_conc_default,  params.min_conc, params.max_conc, params.unit, params.amount])
    results.as_json
  end

  def neat_availability_query(gsid_array, params)
    results= Bottle.find_by_sql(["SELECT sum(b.qty_available_mg_ul) as amount, coa.gsid as gsid, COUNT(b.id) as count,
                                  CASE
                                  WHEN sum(b.qty_available_mg_ul) > ? THEN 'HIGH'
                                  WHEN sum(b.qty_available_mg_ul) between ? AND ?  THEN 'LOW'
                                  ELSE 'NONE'
                                  END as ?
                                  FROM
                                  bottles as b
                                  INNER JOIN coa_summaries as coa
                                  ON
                                  b.coa_summary_id = coa.id
                                  WHERE (coa.gsid IN (?) )
                                  AND b.concentration_mm IS NULL
                                  AND (b.units = ?)
                                  AND (b.qty_available_mg_ul > ?)
                                  GROUP BY gsid;",
                                  params.max, params.min, params.max,
                                  params.kind, gsid_array, params.unit, params.amount])
    results.as_json
  end

  def array_builder(availability, result_array)
    result_array.each { |result| result['neat'] = "NONE"; result['100mM'] = "NONE"; result['20mM'] = "NONE" }
    sum = 0
    query_merger = (availability.neat + availability.twentyul + availability.onehundredul).group_by { |h| h['gsid'] }.map { |gsid, v| v.each { |array| sum += array['count'].to_i; array['count'] = sum }; sum =0; v.reduce(:merge) }
    not_nil_array = result_array.select { |i| i['gsid'] }
    nil_array = result_array.select { |i| i['gsid'].blank? }
    query_array = (not_nil_array + query_merger).group_by { |h| h['gsid'] }.map { |gsid, v| v.reduce(:merge) }
    unless @all
      query_array.each { |i| i['total_count'] = i['count'].to_i }
    end
    query_array + nil_array
  end

  def advanced_bottle_search(options, gsid)
    query_values(options)
    amount_options = find_amounts(options)
    @dsstox_schema = database_initialization
    if options[:neat]
      bottle_neat_search(gsid, amount_options[:neat])
    elsif options[:solution]
      bottle_solution_search(gsid, amount_options[:onehundred])
    else
      find_bottles(gsid)
    end
  end

  def bottle_solution_search(gsid, options)
    Bottle.find_by_sql(["SELECT b.id as bottle_id, b.stripped_barcode AS stripped_barcode,gs.id AS gsid, gs.casrn AS casrn,
                         gs.preferred_name AS preferred_name, gs.dsstox_substance_id AS dsstox_substance_id,  b.qty_available_mg_ul AS qty_available_mg_ul,
                         b.concentration_mm AS concentration_mm, b.units AS units, b.vendor AS vendor, b.coa_summary_id AS COA
                         FROM bottles as b
                         INNER JOIN coa_summaries as coa
                         ON b.coa_summary_id = coa.id
                         INNER JOIN #{@dsstox_schema[:gs]} AS gs
                         ON gs.id = coa.gsid
                         WHERE (coa.gsid IN (?))
                         AND (ifnull(b.concentration_mm,0) between ? AND ?)
                         AND (b.units = ?)
                         AND (b.qty_available_mg_ul > ?);",
                         gsid, options.min_conc, options.max_conc, options.unit, options.amount])
      end

  def bottle_neat_search(gsid, options)
    Bottle.find_by_sql(["SELECT b.id as bottle_id, b.stripped_barcode AS stripped_barcode,gs.id AS gsid, gs.casrn AS casrn,
                         gs.preferred_name AS preferred_name, gs.dsstox_substance_id AS dsstox_substance_id,  b.qty_available_mg_ul AS qty_available_mg_ul,
                         b.concentration_mm AS concentration_mm, b.units AS units, b.vendor AS vendor, b.coa_summary_id AS COA
                         FROM bottles as b
                         INNER JOIN coa_summaries as coa
                         ON b.coa_summary_id = coa.id
                         INNER JOIN #{@dsstox_schema[:gs]} AS gs
                         ON gs.id = coa.gsid
                         WHERE (coa.gsid IN (?))
                         AND b.concentration_mm IS NULL
                         AND (b.units = ?)
                         AND (b.qty_available_mg_ul > ?);",
                         gsid, options.unit, options.amount])
  end

end



