# Handles all of the AJAX requests from taxonomy navigation.
class TaxonomyNavigationController < ApplicationController
  # Returns the set of options for a select field based on the parent id.
  #
  #   GET /taxonomy/dropdown/orders?class=32
  def dropdown_options
    # TODO: merge these conditionals into an arg for the named scope.    
    @taxons = Taxon.send(params[:rank], :parent_id => params[:parent_id])
    render :layout => false
  end

end
