ActionController::Routing::Routes.draw do |map|
  map.resource :user_session
  map.account "/account", :controller => :users, :action => :show
  map.resources :users
  map.taxonomy "/taxonomy", :controller => :taxonomy, :action => :index
  map.resources :species
  map.root :controller => :taxonomy
end
