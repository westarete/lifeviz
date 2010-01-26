class LifespansController < ApplicationController
  before_filter :find_species
  
  def new
    @lifespan = @species.lifespans.new
  end
  
  def create
    @lifespan = @species.lifespans.new(params[:lifespan])
    if @lifespan.save
      redirect_to @species
    else
      flash.now[:failure] = "Lifespan annotation update failed."
      render :new
    end
  end
  
  def edit
    @lifespan = Lifespan.find(params[:id])
  end
  
  def update
    @lifespan = Lifespan.find(params[:id])
    if @lifespan.update_attributes(params[:lifespan])
      redirect_to @species
    else
      flash.now[:failure] = "Lifespan annotation update failed."
      render :edit
    end
  end
  
  private
  
  def find_species
    @species = Species.find(params[:species_id])
  end
  
end
