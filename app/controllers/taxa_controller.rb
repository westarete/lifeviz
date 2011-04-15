class TaxaController < ApplicationController
  before_filter :load_taxonomy
  
  def index
    if params[:taxon] && params[:rank]
      if ! @taxon = Taxon.find_by_name_and_rank(params[:taxon], params[:rank])
        flash[:failure] = "#{params[:rank].capitalize} #{params[:taxon].capitalize} could not be found."
        redirect_to root_path
      end
    else
      @taxon = Taxon.root
    end
    
    @parents = @taxon.parents
    @parents.shift  # Remove UBT/root from the list of parents for Breadcrumbs. 
    @children = @taxon.children.select{|c| !(c.statistics.average_lifespan.blank? or c.statistics.average_birth_weight.blank? or c.statistics.average_adult_weight.blank? or c.statistics.average_litter_size.blank?) }
    
    @title = @taxon.name
  end
end
