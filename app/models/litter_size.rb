class LitterSize < ActiveRecord::Base

  belongs_to :species
  validates_presence_of :measure

end