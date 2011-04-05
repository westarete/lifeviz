class BirthWeight < ActiveRecord::Base
  include Annotation
  
  before_create :set_created_by
  after_create :add_annotation_point
  
  belongs_to :species
  
  validates_presence_of   :species_id
  validates_presence_of   :units
  validates_inclusion_of  :units, :in => %w( Grams Kilograms )
  validates_presence_of   :value_in_grams
  
  def validate
    should_be_greater_than_zero
  end
  
  def should_be_greater_than_zero
    unless value_in_grams.nil?
      if value_in_grams == 0
        errors.add(:value, "needs to be greater than zero")
      elsif !(value_in_grams > 0)
        errors.add(:value, "should be a positive number")
      end
    end
  end
  
  def to_s
    value.to_s
  end
  
  def value
    if value_in_grams && units
      in_units(units)
    else
      @value
    end
  end
  
  def value=(v)
    return if v.blank? || v.nil?
    @value = v
    v = v.to_f
    if self.units
      self.value_in_grams = v.send(units.downcase)
    end
  end
  
  def in_units(units)
    value_in_grams.grams.send("to_#{units.downcase}")
  end
end


# == Schema Information
#
# Table name: birth_weights
#
#  id              :integer         not null, primary key
#  species_id      :integer
#  value_in_grams  :decimal(, )
#  units           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  created_by      :integer
#  created_by_name :string(255)
#

