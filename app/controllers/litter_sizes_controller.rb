class LitterSizesController < ApplicationController
  before_filter :find_species, :require_user
  
  def new
    @litter_size = @species.litter_sizes.new
  end
  
  def create
    @litter_size = LitterSize.new(params[:litter_size])
    @litter_size.species = @species
    if @litter_size.save
      flash[:success] = "Litter size created."
      flash[:karma_updated] = true
      redirect_to @species
    else
      flash.now[:failure] = "Litter size annotation failed becase ", @litter_size.errors.full_messages.to_sentence.downcase, "."
      render :new
    end
  end
  
  def edit
    @litter_size = LitterSize.find(params[:id])
  end
  
  def update
    @litter_size = LitterSize.find(params[:id])
    if @litter_size.update_attributes(params[:litter_size])
      flash[:success] = "Litter size updated."
      redirect_to @species
    else
      flash.now[:failure] = "Litter size update failed."
      render :edit
    end
  end
  
  def destroy
    @litter_size = LitterSize.find(params[:id])
    @litter_size.destroy
    flash[:success] = "Litter size deleted."
    redirect_to @species
  end
  
  private
  
  def find_species
    @species = Species.find(params[:species_id])
  end
  
end
