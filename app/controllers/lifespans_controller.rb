class LifespansController < ApplicationController
  before_filter :find_species
  
  def new
    @lifespan = @species.lifespans.new
  end
  
  def create
    @lifespan = Lifespan.new(params[:lifespan])
    @lifespan.species = @species
    if @lifespan.save
      flash[:success] = "Lifespan annotation created."
      redirect_to @species
    else
      flash.now[:failure] = "Lifespan annotation create failed."
      render :new
    end
  end
  
  def edit
    @lifespan = Lifespan.find(params[:id])
  end
  
  def update
    @lifespan = Lifespan.find(params[:id])
    if @lifespan.update_attributes(params[:lifespan])
      flash[:success] = "Lifespan annotation updated."
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
