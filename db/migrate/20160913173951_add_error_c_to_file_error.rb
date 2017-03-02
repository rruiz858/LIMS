class AddErrorCToFileError < ActiveRecord::Migration
  def change
    add_column :file_errors, :error_c, :text
  end
end
