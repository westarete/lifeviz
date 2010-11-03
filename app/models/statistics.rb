class Statistics < ActiveRecord::Base

  set_table_name "statistics" 
  
  belongs_to :taxon, :foreign_key => "taxon_id"
end