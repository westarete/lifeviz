class Lifespan < ActiveRecord::Base
  require 'quantity/all'
  include Annotation
  
  before_create :set_created_by
  after_create :add_annotation_point
  
  belongs_to :species
  
  validates_presence_of   :species_id
  validates_presence_of   :units
  validates_inclusion_of  :units, :in => %w( Days Months Years )
  validates_presence_of   :value_in_days
  
  def validate
    should_be_greater_than_zero
  end
  
  def should_be_greater_than_zero
    unless value_in_days.nil?
      if value_in_days == 0
        errors.add(:value, "needs to be greater than zero")
      elsif !(value_in_days > 0)
        errors.add(:value, "should be a positive number")
      end
    end
  end
  
  def after_save
    self.species.statistics.calculate_lifespan
  end
  
  def to_s
    value.to_s
  end
  
  def value
    if value_in_days && units
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
      self.value_in_days = Quantity.new(v, units.downcase.to_sym).days
    end
  end
  
  def in_units(units)
    Quantity.new(value_in_days, :days).send("to_#{units.downcase}")
  end
end

# == Schema Information
#
# Table name: lifespans
#
#  id               :integer         not null, primary key
#  species_id       :integer
#  created_at       :datetime
#  updated_at       :datetime
#  value_in_days    :decimal(, )
#  units            :string(255)
#  created_by       :integer
#  created_by_name  :string(255)
#  citation         :string(255)
#  citation_context :text
#

