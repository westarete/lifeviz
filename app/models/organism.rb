# == Schema Information
#
# Table name: organisms
#
#  id         :integer         not null, primary key
#  taxon_id   :integer
#  name       :string(255)
#  synonyms   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Organism < ActiveRecord::Base
  belongs_to :taxon
  
end
