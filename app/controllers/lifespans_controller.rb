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
      add_annotation_point(1)
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
      add_annotation_point(1)
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
  
  def add_annotation_point(value)
    current_user.karma.buckets.lifevis_annotations += 1
    flash[:karma_updated] = true
  end
  
end
