class MentorPostdoc < ActiveRecord::Base
  belongs_to      :postdoc,
                  :class_name => "User",
                  :foreign_key => "post_doc_id"

  belongs_to      :cor,
                  :class_name => "User",
                  :foreign_key => "cor_id"
end
