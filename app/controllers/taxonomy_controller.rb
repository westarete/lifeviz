class TaxonomyController < ApplicationController
  before_filter :load_taxonomy
  
  def index
    @species = Species.all
  end

end
