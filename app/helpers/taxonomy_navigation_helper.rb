module TaxonomyNavigationHelper
  
  # Returns an array of paired ids and names for the taxonomy navigation
  # dropdowns.
  def dropdown_options(taxons=[])
    # Map to sets of names and ids.
    elements = taxons.map { |t| [t.name, t.id] }
    # Prepend the "Any" option.
    elements.unshift(['Any', ''])
    options_for_select(elements)
  end
  
end
