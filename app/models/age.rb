# == Schema Information
#
# Table name: ages
#
#  id                           :integer         not null, primary key
#  taxon_id                     :integer
#  synonyms                     :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  initial_mortality_rate       :float
#  mortality_rate_doubling_time :float
#  maximum_longevity            :float
#  phenotype                    :string(255)
#

class Age < ActiveRecord::Base
  belongs_to :species
  validates_presence_of :taxon_id
  validates_uniqueness_of :taxon_id
  
  def self.find_or_create_by_taxon_id(taxon_id)
    find_by_taxon_id(taxon_id) || 
    create(:taxon_id => taxon_id)
  end
end
