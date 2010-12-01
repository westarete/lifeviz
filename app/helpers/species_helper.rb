module SpeciesHelper
  
  def species_header(taxon)
    if taxon.id != 1
      "#{@taxon.rank_in_words}: #{@taxon.name}"
    else
      "Welcome to Lifeviz."
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
