class Query < ActiveRecord::Base
  validates :name, :label, :description, :sql, presence: true
  validates :sql, format: {:without => /delete+|drop+|update+|create+|insert+|truncate+|["';]+/i ,  message: "SQL contiains illegal characters "}
  validate :check_sql


  private

  def check_sql
    if errors.blank?
      conditions_params = self.conditions.strip.split(/\r\n/).collect { |x| x.strip || x }.reject(&:blank?)
      condition_count = conditions_params.count
      formatted_sql = self.sql.gsub(/[\r\n]+/, ' ').strip
      sql_string = "Select count(*) from " + formatted_sql
      temp_array = conditions_params.unshift(sql_string)
      match_count = sql_string.scan(/\?/).size
      if match_count == condition_count
        insert(temp_array)
      else
        errors.add(:conditions, ": Incorrect number of conditions")
      end
    end
  end

  def insert(temp_array)
    begin
      sanitize = ActiveRecord::Base.send(:sanitize_sql_array, temp_array)
      query = ActiveRecord::Base.connection.execute(sanitize)
    rescue => @error_string
      if @error_string.present?
        errors.add(:sql, " #{@error_string}")
        Rails.logger.error @error_string
      end
    end
    unless @error_string.present?
     !(query.first[0].blank?) ? self.count = query.first[0] : self.count = 0
      self.complete_query = sanitize
    end
  end
end
