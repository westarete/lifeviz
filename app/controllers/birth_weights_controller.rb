class BirthWeightsController < ApplicationController
  before_filter :find_species
  
  def new
    @birth_weight = @species.birth_weights.new
  end
  
  def create
    @birth_weight = BirthWeight.new(params[:birth_weight])
    @birth_weight.species = @species
    if @birth_weight.save
      flash[:success] = "Birth weight created."
      redirect_to @species
    else
      flash.now[:failure] = "Birth weight creation failed."
      render :new
    end
  end
  
  def edit
    @birth_weight = BirthWeight.find(params[:id])
  end
  
  def update
    @birth_weight = BirthWeight.find(params[:id])
    if @birth_weight.update_attributes(params[:birth_weight])
      flash[:success] = "Birth weight updated."
      redirect_to @species
    else
      flash.now[:failure] = "Birth weight update failed."
      render :edit
    end
  end
    
private
  
  def find_species
    @species = Species.find(params[:species_id])
  end
  
end