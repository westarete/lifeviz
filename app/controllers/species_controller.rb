class SpeciesController < ApplicationController
  before_filter :load_taxonomy

  def new
    @species = Species.new
    @taxon = Taxon.root
  end

  def create
    @taxon = Taxon.root
    if params[:genus]
      @genus = Taxon.find(params[:genus])
      @species = Species.new(params[:species])
      @species.rank = 6
      @species.parent_id = @genus.id
      if @species.save
        flash[:success] = "Species saved."
        redirect_to species_path(:id => @species.id)
      else
        flash.now[:failure] = "Species failed to save."
        render :new
      end
    else
      flash.now[:failure] = "You need to select a genus."
      render :new
    end
  end

  def show
    @species = Species.find(params[:id])
    @title = @species.name
  end

  def edit
    @species = Species.find(params[:id])
    @age = @species.age ? @species.age : @species.build.age
  end

  def update
    @species = Species.find(params[:id])
    @age = Age.find_or_create_by_taxon_id(params[:id])
    if Species.transaction {
        @species.update_attributes(params[:species])
        @age.update_attributes(params[:species][:age])
    } then
      flash[:success] = "Species updated."
      redirect_to species_path(:id => @species.id)
    else
      flash.now[:failure] = "Species failed to update."
      render :update
    end
  end

end
