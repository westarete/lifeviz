class Lifespan < ActiveRecord::Base
  belongs_to :species
  validates_presence_of   :species_id
  validates_presence_of   :units
  validates_inclusion_of  :units, :in => %w( Days Months Years )
  validates_presence_of   :value
  
  def self.find_or_create_by_species_id(species_id)
    find_by_species_id(species_id) || 
    create(:species_id => species_id)
  end
  
  def to_s
    if units
      "#{value} #{units}".downcase
    else
      ""
    end
  end
  
  def value
    if value_in_days && units
      in_units(units)
    else
      @value
    end
  end
  
  def value=(v)
    @value = v
    v = v.to_f
    self.value_in_days = case units
      when 'Years'  then v * 365
      when 'Months' then v * 30
      when 'Days'   then v
    end
  end
  
  def in_units(unit)
    case unit
      when 'Years'  then value_in_days.to_i / 365
      when 'Months' then value_in_days.to_i / 30
      when 'Days'   then value_in_days
    end
  end
  
end



# == Schema Information
#
# Table name: lifespans
#
#  id            :integer         not null, primary key
#  species_id    :integer
#  created_at    :datetime
#  updated_at    :datetime
#  value_in_days :decimal(, )
#  units         :string(255)
#

