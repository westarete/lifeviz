module SpeciesHelper
  
  # Get the mode of the lifespans' units, and the average of the lifespan values, and return it in a string
  def lifespan_with_units(species)
    if species.lifespans.any?
      case species.lifespans.group_by(&:units).values.max_by(&:size).first.units
      when "Days"
        "%.2f Days" % species.lifespan_in_days
      when "Months"
        "%.2f Months" % (species.lifespan_in_days / 30.0)
      when "Years"
        "%.2f Years" % (species.lifespan_in_days / 365.0)
      end
    else
      "N/A"
    end
  end
  
  # Get the mode of the birth_weights' units, and the average of the birth_weight values, and return it in a string
  def birth_weight_with_units(species)
    if species.birth_weights.any?
      case species.birth_weights.group_by(&:units).values.max_by(&:size).first.units
      when "Grams"
        "%.2f Grams" % species.birth_weight_in_grams
      when "Kilograms"
        "%.2f Kilograms" % (species.birth_weight_in_grams / 1000.0)
      end
    else
      "N/A"
    end
  end
  
end
