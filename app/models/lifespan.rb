class Lifespan < ActiveRecord::Base
  belongs_to :species
  validates_presence_of   :species_id
  validates_presence_of   :units
  validates_inclusion_of  :units, :in => %w( Days Months Years )
  validates_presence_of   :value
  
  attr_accessor :value
  
  def self.find_or_create_by_species_id(species_id)
    find_by_species_id(species_id) || 
    create(:species_id => species_id)
  end
  
  def to_s
    value.to_s
  end
  
  def value
    return 0 if value_in_days == 0
    case units
      when 'Years'  then value_in_days / 365
      when 'Months' then value_in_days / 30
      when 'Days'   then value_in_days
    end
  end
  
  def value=(v)
    v = v.to_i
    self.value_in_days = case units
      when 'Years'  then v * 365.0
      when 'Months' then v * 30.0
      when 'Days'   then v
    end

  end
  
end


# == Schema Information
#
# Table name: lifespans
#
#  id                 :integer         not null, primary key
#  species_id         :integer
#  created_at         :datetime
#  updated_at         :datetime
#  value_in_days      :float
#  units              :string
#