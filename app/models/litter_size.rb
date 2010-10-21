class LitterSize < ActiveRecord::Base
  include Annotation
  
  before_create :set_created_by
  after_create :add_annotation_point
  
  belongs_to :species
  
  validates :species_id, :presence => true
  validates :measure, :presence => true
  validate :should_be_greater_than_zero
  
  def should_be_greater_than_zero
    unless measure.nil?
      if measure == 0
        errors.add(:measure, "needs to be greater than zero")
      elsif !(measure > 0)
        errors.add(:measure, "should be a positive number")
      end
    end
  end

end



# == Schema Information
#
# Table name: litter_sizes
#
#  id               :integer         not null, primary key
#  species_id       :integer         not null
#  measure          :integer         not null
#  created_at       :datetime
#  updated_at       :datetime
#  created_by       :integer
#  created_by_name  :string(255)
#  citation         :string(255)
#  citation_context :text
#

