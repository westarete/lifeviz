ActionController::Routing::Routes.draw do |map|
  map.resource :user_session
  map.resources :users
  map.resources :species
  
  # AJAX Navigation
  map.taxonomy_dropdown '/taxonomy/dropdowns/:rank', :controller => :taxonomy_navigation, :action => :dropdown_options, :conditions => {:method => :get}
  
  map.root :controller => :species
end
