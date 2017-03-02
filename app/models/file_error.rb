class FileError < ActiveRecord::Base
  belongs_to :errorable, polymorphic: true
end
