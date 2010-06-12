class AdultWeight < ActiveRecord::Base
  
  belongs_to :species
  validates_presence_of :measure

end