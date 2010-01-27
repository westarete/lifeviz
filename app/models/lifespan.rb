class Lifespan < ActiveRecord::Base
  belongs_to :species
  validates_presence_of :species_id
  validates_numericality_of :value
  
  attr_accessor :units
  
  def self.find_or_create_by_species_id(species_id)
    find_by_species_id(species_id) || 
    create(:species_id => species_id)
  end
  
  def to_s
    value.to_s
  end
  
end


# == Schema Information
#
# Table name: lifespans
#
#  id         :integer         not null, primary key
#  species_id :integer
#  created_at :datetime
#  updated_at :datetime
#  value      :float
#
