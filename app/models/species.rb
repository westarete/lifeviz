# == Schema Information
#
# Table name: species
#
#  id         :integer         not null, primary key
#  taxon_id   :integer
#  name       :string(255)
#  synonyms   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Species < ActiveRecord::Base
  belongs_to :taxon
  
end
