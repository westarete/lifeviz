class AdultWeightsController < ApplicationController
  before_filter :find_species
  
  def new
    @adult_weight = @species.adult_weights.new
  end
  
  def create
    @adult_weight = AdultWeight.new(params[:adult_weight])
    @adult_weight.species = @species
    if @adult_weight.save
      flash[:success] = "Adult weight created."
      redirect_to @species
    else
      flash.now[:failure] = "Adult weight creation failed."
      render :new
    end
  end
  
private
  
  def find_species
    @species = Species.find(params[:species_id])
  end
  
end
