class AdultWeightsController < ApplicationController
  before_filter :find_species, :require_user
  
  def new
    @adult_weight = @species.adult_weights.new
  end
  
  def create
    @adult_weight = AdultWeight.new(params[:adult_weight])
    @adult_weight.species = @species
    if @adult_weight.save
      flash[:success] = "Adult weight created."
      flash[:karma_updated] = true
      flash[:karma_increased] = "You just received 1 point of karma for contributing a new annotation. Your total karma is now #{current_user.karma.total}, and your level is #{current_user.level}"
      redirect_to @species
    else
      flash.now[:failure] = "Adult weight annotation failed becase ", @adult_weight.errors.full_messages.to_sentence.downcase, "."
      render :new
    end
  end
  
  def edit
    @adult_weight = AdultWeight.find(params[:id])
  end
  
  def update
    @adult_weight = AdultWeight.find(params[:id])
    if @adult_weight.update_attributes(params[:adult_weight])
      flash[:success] = "Adult weight updated."
      redirect_to @species
    else
      flash.now[:failure] = "Adult weight update failed."
      render :edit
    end
  end
  
  def destroy
    @adult_weight = AdultWeight.find(params[:id])
    @adult_weight.destroy
    flash[:success] = "Adult weight deleted."
    redirect_to @species
  end
  
  private
  
  def find_species
    @species = Species.find(params[:species_id])
  end
  
end
