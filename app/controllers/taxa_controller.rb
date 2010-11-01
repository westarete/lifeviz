class TaxaController < ApplicationController
  before_filter :load_taxonomy
  
  def index
    if params[:taxon] && params[:rank]
      if ! @taxon = Taxon.find_by_name_and_rank(params[:taxon], params[:rank])
        @taxon = Taxon.root
        @disable_remaining_dropdowns = "disabled"
        flash.now[:notice] = "#{params[:rank].capitalize} #{params[:taxon].capitalize} could not be found."
      else
        @disable_remaining_dropdowns = false
      end
    else
      @taxon = Taxon.root
      @disable_remaining_dropdowns = "disabled"
    end
    
    @taxon_ancestry = @taxon.full_ancestry(:include_children => true) # for taxon dropdowns
    @rank = @taxon.rank
    @children = @taxon.children
  end
  
  # This populates the taxon dropdowns that run across the top of the page
  # /taxa/1234/children and returns a list of 1234's children terms.
  def children  
    @children = Taxon.find_all_by_parent_id(params[:id], :order => 'name ASC')
    
    respond_to do |format|
      format.json do 
        render :json => @children.to_json(:jstree => true)
      end
    end
  end
  
  def data
    if params[:taxon_id] && ! params[:taxon_id].blank?
      @taxon = Taxon.find(params[:taxon_id])
    else
      @taxon = Taxon.find(1)
    end
    respond_to do |format|
      format.html do
        @children = @taxon.children
        render :partial => "table", :layout => false
      end
      format.json do
        render :json =>  @taxon.children_of_rank(@taxon.rank + 1).to_json(
                 :only => :name,
                 :methods => [
                   :avg_lifespan,
                   :avg_birth_weight,
                   :avg_adult_weight,
                   :avg_litter_size,
                   :id
                 ])
      end
    end
  end
  
  # Returns the set of options for a select field based on the parent id.
  #
  #   GET /taxonomy/dropdown/orders?class=32
  def dropdown_options
    # TODO: merge these conditionals into an arg for the named scope.    
    @taxons = Taxon.send(params[:rank], :parent_id => params[:parent_id])
    render :layout => false
  end

end
