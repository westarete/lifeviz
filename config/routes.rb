ActionController::Routing::Routes.draw do |map|
  map.resource :user_session
  map.resources :users
  map.resources :species, :collection => { :data => :get }
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
