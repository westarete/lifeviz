class BirthWeight < ActiveRecord::Base
  belongs_to :species
  validates_presence_of   :species_id
  validates_presence_of   :units
  validates_inclusion_of  :units, :in => %w( Grams Kilograms )
  validates_presence_of   :value_in_grams

  def to_s
    if units
      "#{value} #{units}".downcase
    else
      ""
    end
  end

  def value
    if value_in_grams && units
      in_units(units)
    else
      @value
    end
  end
  
  def value=(v)
    @value = v
    v = v.to_f
    self.value_in_grams = case units
      when 'Grams' then v
      when 'Kilograms' then v * 1000
    end
  end
  
  
  def in_units(units)
    case units
      when 'Grams'  then value_in_grams
      when 'Kilograms' then value_in_grams.to_i / 1000
    end
  end
end

# == Schema Information
#
# Table name: birth_weights
#
#  id             :integer         not null, primary key
#  species_id     :integer
#  value_in_grams :decimal(, )
#  units          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

