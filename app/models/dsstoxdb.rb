include DsstoxSchema
class Dsstoxdb < ActiveRecord::Base
  schema_hash = database_initialization
  database = schema_hash[:database]
  unless Rails.env.test?
    establish_connection(database.to_sym)
  end
  self.abstract_class = true
end
