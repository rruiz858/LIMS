require 'mysql2'
module SourceSubstanceGenericMapping
  extend ActiveSupport::Concern
  private
  def source_generic_mapping(source_substances, username)
    @insert_count = 0
    schema = database_initialization
    connection = ActiveRecord::Base.connection
    begin
      source_substances.each do |ss|
        id = ss.attributes["id"]
        connection.execute(
        "INSERT INTO #{schema[:sgm]} (fk_source_substance_id, fk_generic_substance_id, connection_reason, created_by, updated_by, created_at, updated_at)
          SELECT ss.id as SS_ID, sm.fk_generic_substance_id AS GSID,
          CASE
            WHEN (SELECT COUNT(*) from (SELECT MIN(sm.rank) AS SM_RANK, sm.fk_generic_substance_id AS GSID
              FROM #{schema[:ss]} as ss
              INNER JOIN #{schema[:ssi]} as ssi
              ON ssi.fk_source_substance_id = ss.id
              INNER JOIN #{schema[:sm]} as sm
              ON sm.identifier = ssi.identifier
              WHERE (sm.synonym_type = 'CAS-RN' AND ss.id = #{id})
              OR (sm.rank BETWEEN 9 AND 12 AND ss.id = #{id})
              GROUP BY GSID) as count)>1
            THEN 'MATCHED CASRN, NAME MATCHED OTHER'

            WHEN (SELECT COUNT(*) from (SELECT MIN(sm.rank) AS SM_RANK, sm.fk_generic_substance_id AS GSID
              FROM #{schema[:ss]} as ss
              INNER JOIN #{schema[:ssi]} as ssi
              ON ssi.fk_source_substance_id = ss.id
              INNER JOIN #{schema[:sm]} as sm
              ON sm.identifier = ssi.identifier
              WHERE (sm.synonym_type = 'CAS-RN' AND ss.id = #{id})
              OR (sm.rank BETWEEN 9 AND 12 AND ss.id = #{id})
              HAVING COUNT(*)=1) as count)=1
            AND
              (SELECT  distinct(SM_TYPE) from (SELECT MIN(sm.rank) AS SM_RANK, sm.fk_generic_substance_id AS GSID, sm.synonym_type AS SM_TYPE
              FROM #{schema[:ss]} as ss
              INNER JOIN #{schema[:ssi]} as ssi
              ON ssi.fk_source_substance_id = ss.id
              INNER JOIN #{schema[:sm]} as sm
              ON sm.identifier = ssi.identifier
              WHERE (sm.synonym_type = 'CAS-RN' AND ss.id = #{id})
              OR (sm.rank BETWEEN 9 AND 12 AND ss.id = #{id})
              GROUP BY  GSID LIMIT 1) as SM_TYPE)='CAS-RN'
            THEN 'MATCHED CASRN'

            WHEN (SELECT COUNT(*) from (SELECT MIN(sm.rank) AS SM_RANK, sm.fk_generic_substance_id AS GSID
              FROM #{schema[:ss]} as ss
              INNER JOIN #{schema[:ssi]} as ssi
              ON ssi.fk_source_substance_id = ss.id
              INNER JOIN #{schema[:sm]} as sm
              ON sm.identifier = ssi.identifier
              WHERE (sm.synonym_type = 'CAS-RN' AND  ss.id = #{id})
              OR (sm.rank BETWEEN 9 AND 12 AND ss.id = #{id})
              HAVING COUNT(*)=1) as count)=1
            AND
              (SELECT  distinct(SM_TYPE) from (SELECT MIN(sm.rank) AS SM_RANK, sm.fk_generic_substance_id AS GSID, sm.synonym_type AS SM_TYPE
              FROM #{schema[:ss]} as ss
              INNER JOIN #{schema[:ssi]} as ssi
              ON ssi.fk_source_substance_id = ss.id
              INNER JOIN #{schema[:sm]} as sm
              ON sm.identifier = ssi.identifier
              WHERE (sm.synonym_type ='CAS-RN' AND ss.id = #{id})
              OR (sm.rank BETWEEN 9 AND 12 AND ss.id = #{id})
              GROUP BY  GSID LIMIT 1) as SM_TYPE) !='CAS-RN'
              THEN 'MATCHED NAME'

            ELSE 'MATCHED BY CASRN AND NAME' END
           AS 'connectivity_reason','#{username}' AS created_by, '#{username}' AS updated_by, now() AS created_at, now() AS updated_at

            FROM #{schema[:ss]} AS ss
            INNER JOIN #{schema[:ssi]} as ssi
            ON ssi.fk_source_substance_id = ss.id
            INNER JOIN #{schema[:sm]} as sm
            ON sm.identifier = ssi.identifier
            WHERE (sm.synonym_type = 'CAS-RN' AND ss.id = #{id})
            OR (sm.rank BETWEEN 9 AND 12 AND ss.id = #{id})
            GROUP BY SS_ID

           UNION

           SELECT ss.id as SS_ID, NULL AS GSID, 'NO HIT' AS 'connectivity_reason','#{username}' AS created_by, '#{username}' AS updated_by, now() AS created_at, now() AS updated_at
           FROM #{schema[:ss]} AS ss
           INNER JOIN #{schema[:ssi]} as ssi
           on ssi.fk_source_substance_id = ss.id
           WHERE 	(ss.id = #{id} AND ssi.identifier_type = 'CASRN' AND ssi.identifier NOT IN (SELECT sm.identifier FROM #{schema[:sm]} AS sm WHERE sm.rank = 5))
           OR (ss.id = #{id} AND ssi.identifier_type = 'NAME' AND ssi.identifier NOT IN (SELECT sm.identifier FROM #{schema[:sm]} AS sm WHERE sm.rank BETWEEN 9 AND 12))
           GROUP BY SS_ID HAVING count(*)=2;")
        @insert_count += 1
      end
      # puts "Inserted #{@insert_count} source_generic_mapping_records into #{schema[:database]}"
      return @insert_count
    rescue Mysql2::Error => e #check for errors in database
      puts e.error
    ensure
      connection.close
    end
  end
end