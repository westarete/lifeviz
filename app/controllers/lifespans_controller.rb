class LifespansController < ApplicationController
  before_filter :find_species, :require_user
  
  def new
    @lifespan = @species.lifespans.new
  end
  
  def create
    @lifespan = Lifespan.new(params[:lifespan])
    @lifespan.species = @species
    if @lifespan.save
      flash[:success] = "Lifespan annotation created."
      add_annotation_point(1)
      redirect_to @species
    else
      flash.now[:failure] = "Lifespan annotation failed becase ", @lifespan.errors.full_messages.to_sentence.downcase, "."
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
      add_annotation_point(1)
      redirect_to @species
    else
      flash.now[:failure] = "Lifespan annotation update failed."
      render :edit
    end
  end
  
  def destroy
    @lifespan = Lifespan.find(params[:id])
    @lifespan.destroy
    flash[:success] = "Lifespan deleted."
    redirect_to @species
  end
  
  private
  
  def find_species
    @species = Species.find(params[:species_id])
  end
  
end
