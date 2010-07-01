class LitterSize < ActiveRecord::Base

  belongs_to :species
  validates_presence_of :species_id
  validates_presence_of :measure

  def validate
    should_be_greater_than_zero
  end
  
  def should_be_greater_than_zero
    unless measure.nil?
      if measure == 0
        errors.add(:litter_size, "needs to be greater than zero")
      elsif !(measure > 0)
        errors.add(:litter_size, "should be a positive number")
      end
    end
  end

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

