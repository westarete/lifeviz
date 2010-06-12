class LitterSizesController < ApplicationController
  before_filter :find_species
  
  def new
    @litter_size = @species.litter_sizes.new
  end
  
  def create
    @litter_size = LitterSize.new(params[:litter_size])
    @litter_size.species = @species
    if @litter_size.save
      flash[:success] = "Litter size created."
      redirect_to @species
    else
      flash.now[:failure] = "Litter size creation failed."
      render :new
    end
  end
  
private
  
  def find_species
    @species = Species.find(params[:species_id])
  end
  
end
