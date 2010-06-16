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
end
