class SpeciesController < ApplicationController
  before_filter :load_taxonomy
  
  def index
    if params[:genus].nil? || ! @taxon = Taxon.find_by_name(params[:genus].capitalize)
        flash.now[:notice] = "Genus #{params[:genus].capitalize if params[:genus]} could not be found."
        redirect_back_or_default '/'
    else
      @taxon_ancestry = @taxon.full_ancestry(:include_children => false) # for taxon dropdowns
      @rank = @taxon.rank
      @species = @taxon.paginated_sorted_species(params[:page])
    end
  end

  # Clinton: I don't know if we actually use this. Commenting it out to see if
  #          stuff breaks. Now, the graph uses javascript and the table in the
  #          view to get its data.
  # def species_data
  #   if params[:taxon_id] && ! params[:taxon_id].blank?
  #     @taxon = Taxon.find(params[:taxon_id])
  #   else
  #     @taxon = Taxon.find(1)
  #   end
  #   respond_to do |format|
  #     format.html do
  #       @children = @taxon.species
  #       render :partial => "table", :layout => false
  #     end
  #     format.json do
  #       render :json =>  @taxon.children_of_rank(@taxon.rank + 3).to_json(
  #                :only => :name,
  #                :methods => [
  #                  :avg_lifespan,
  #                  :avg_birth_weight,
  #                  :avg_adult_weight,
  #                  :avg_litter_size
  #                ])
  #     end
  #   end
  # end

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
