class Age < ActiveRecord::Base
  belongs_to :species
  validates_presence_of :species_id
  validates_uniqueness_of :species_id
  
  def self.find_or_create_by_species_id(species_id)
    find_by_species_id(species_id) || 
    create(:species_id => species_id)
  end
end

# == Schema Information
#
# Table name: ages
#
#  id                :integer         not null, primary key
#  species_id        :integer
#  created_at        :datetime
#  updated_at        :datetime
#  maximum_longevity :float
#  phenotype         :string(255)
#

