class CreateTox21 < ActiveRecord::Migration
  def change
    create_table :tox_21_chemicals do |t|
      t.string :t_tox21_id
      t.string :t_original_sample_id
      t.string :t_partner
      t.string :t_tox21_ntp_sid
      t.string :t_tox21_ncgc_id
      t.string :t_pubchem_regid
      t.integer :t_pubchem_sid
      t.integer :t_pubchem_cid
      t.string :t_pubchem_name
      t.string :t_pubchem_cas
      t.string :t_qc_grade_id
      t.string :t_tox21_id
    end
  end
end
