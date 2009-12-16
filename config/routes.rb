ActionController::Routing::Routes.draw do |map|
  map.taxonomy "/taxonomy", :controller => :taxonomy, :action => :index
  map.resources :species
  map.root :controller => :taxonomy
end
