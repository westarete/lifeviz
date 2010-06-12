class LitterSize < ActiveRecord::Base

  belongs_to :species
  validates_presence_of :measure

end
# == Schema Information
#
# Table name: litter_sizes
#
#  id         :integer         not null, primary key
#  species_id :integer         not null
#  measure    :integer         not null
#  created_at :datetime
#  updated_at :datetime
#

