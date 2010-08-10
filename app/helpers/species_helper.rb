module SpeciesHelper
  
  def species_header(taxon)
    if taxon.id != 1
      "#{@taxon.rank_in_words}: #{@taxon.name}"
    else
      "Welcome to Lifeviz."
    end
  end
  
  # Get the mode of the lifespans' units, and the average of the lifespan values, and return it in a string
  def lifespan_with_units(species)
    if species.avg_lifespan
      case species.lifespans.group_by(&:units).values.max{|a,b| a.size <=> b.size}.first.units
      when "Days"
        "%.2f Days" % species.lifespan_in_days
      when "Months"
        "%.2f Months" % (species.avg_lifespan / 30.0)
      when "Years"
        "%.2f Years" % (species.avg_lifespan / 365.0)
      end
    else
      "N/A"
    end
  end
  
  # Get the mode of the birth_weights' units, and the average of the birth_weight values, and return it in a string
  def birth_weight_with_units(species)
    if species.avg_birth_weight
      case species.birth_weights.group_by(&:units).values.max{|a,b| a.size <=> b.size}.first.units
      when "Grams"
        "%.2f Grams" % species.avg_birth_weight
      when "Kilograms"
        "%.2f Kilograms" % (species.avg_birth_weight / 1000.0)
      end
    else
      "N/A"
    end
  end
  
  # Get the mode of the adult_weights' units, and the average of the adult_weight values, and return it in a string
  def adult_weight_with_units(species)
    if species.avg_adult_weight
      case species.adult_weights.group_by(&:units).values.max{|a,b| a.size <=> b.size}.first.units
      when "Grams"
        "%.2f Grams" % species.avg_adult_weight
      when "Kilograms"
        "%.2f Kilograms" % (species.avg_adult_weight / 1000.0)
      end
    else
      "N/A"
    end
  end
  
  # Get the average lifespan, else display N/A
  def litter_size(species)
    if species.avg_litter_size
      "%.1f" % species.avg_litter_size
    else
      "N/A"
    end
  end

  # Returns an array of paired ids and names for the taxonomy navigation
  # dropdowns.
  def options_for_taxonomy_select(taxons=[], selected=nil)
    # Map to sets of names and ids.
    elements = taxons.map { |t| [t.name, "#{t.rank_in_words}/#{t.name}"] }
    # Prepend the "Any" option.
    elements.unshift(['Any', ''])
    options_for_select elements, selected
  end
  
  def taxon_dropdowns(taxon, ancestry)
    lineage = taxon.parents
    lineage << taxon
    returning String.new do |html|
      ancestry.each_with_index do |ancestor_taxa, rank|
        rank_in_words = ancestor_taxa.first.rank_in_words
        html << controller.render_to_string(:partial => '/taxa/taxon_select', :layout => false, :locals => { :children => ancestor_taxa, :rank => rank, :rank_in_words => rank_in_words, :selected => lineage[rank + 1], :last => (rank + 1 == ancestry.length) })
      end
    end
  end
  
end
