# Handles all of the AJAX requests from taxonomy navigation.
class TaxonomyNavigationController < ApplicationController

  # Returns the set of options for a select field based on the parent id.
  #
  #   GET /taxonomy/dropdown/orders?class=32
  def dropdown_options
    @taxons = Taxon.send(params[:rank], :conditions => ['parent_id = ?', params[:parent_id]])
  end

end
