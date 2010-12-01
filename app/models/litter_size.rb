class LitterSize < ActiveRecord::Base
  include Annotation
  
  before_create :set_created_by
  after_create :add_annotation_point
  
  belongs_to :species
  
  validates_presence_of :species_id
  validates_presence_of :value

  def validate
    should_be_greater_than_zero
  end
  
  def should_be_greater_than_zero
    unless value.nil?
      if value == 0
        errors.add(:value, "needs to be greater than zero")
      elsif !(value > 0)
        errors.add(:value, "should be a positive number")
      end
    end
  end
  
  def after_save
    self.species.statistics.calculate_litter_size
  end
  
  def after_destroy
    self.species.statistics.calculate_litter_size
  end
  
  def to_s
    value.to_s
  end
end

# == Schema Information
#
# Table name: litter_sizes
#
#  id               :integer         not null, primary key
#  species_id       :integer         not null
#  value            :decimal(, )     not null
#  created_at       :datetime
#  updated_at       :datetime
#  created_by       :integer
#  created_by_name  :string(255)
#  citation         :string(255)
#  citation_context :text
#

