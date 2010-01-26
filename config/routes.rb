ActionController::Routing::Routes.draw do |map|
  map.resource :user_session
  map.resources :users
  
  map.resources :species, :collection => { :data => :get }
  map.with_options :controller => :ages do |a|
    a.new_age '/species/:species_id/ages/new', :action => :new, :conditions => {:method => :get}
    a.edit_age '/species/:species_id/ages/:id/edit', :action => :edit, :conditions => {:method => :get}
    a.connect '/species/:species_id/ages', :action => :create, :conditions => {:method => :post}
    a.connect '/species/:species_id/ages/:id', :action => :update, :conditions => {:method => :put}
  end
  
  map.taxon '/:rank/:taxon_id',
    :controller => :species,
    :action => :index,
    :rank => /(kingdom|phylum|class|order|family|genus)/,
    :conditions => {:method => :get}
  
  # AJAX Navigation
  map.taxonomy_dropdown '/taxonomy/dropdown/:rank', 
    :controller => :taxonomy_navigation, 
    :action => :dropdown_options, 
    :rank => /(kingdoms|phylums|classes|orders|families|genuses|species)/,
    :conditions => {:method => :get}
  
  map.root :controller => :species
end
