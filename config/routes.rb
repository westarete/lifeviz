Lifeviz::Application.routes.draw do
  resource :user_session
  resources :users
  resources :species do
    collection do
      get :data
      get :species_data
    end
    member do
      get :children
    end
  end

  match '/genus/:genus' => 'species#index', :as => "genus", :via => "get"
  match '/species/:species_id/lifespans/new' => 'lifespans#new', :as => "new_lifespan", :via => "get"
  match '/species/:species_id/lifespans/:id/edit' => 'lifespans#edit', :as => "edit_lifespan", :via => "get"
  match '/species/:species_id/lifespans/:id' => 'lifespans#destroy', :as => "destroy_lifespan", :via => "delete"
  match '/species/:species_id/lifespans' => 'lifespans#create', :via => "post"
  match '/species/:species_id/lifespans/:id' => 'lifespans#update', :via => "put"
  match '/species/:species_id/adult_weights/new' => 'adult_weights#new', :as => "new_adult_weight", :via => "get"
  match '/species/:species_id/adult_weights/:id/edit' => 'adult_weights#edit', :as => "edit_adult_weight", :via => "get"
  match '/species/:species_id/adult_weights/:id' => 'adult_weights#destroy', :as => "destroy_adult_weight", :via => "delete"
  match '/species/:species_id/adult_weights' => 'adult_weights#create', :via => "post"
  match '/species/:species_id/adult_weights/:id' => 'adult_weights#update', :via => "put"
  match '/species/:species_id/birth_weights/new' => 'birth_weights#new', :as => "new_birth_weight", :via => "get"
  match '/species/:species_id/birth_weights/:id/edit' => 'birth_weights#edit', :as => "edit_birth_weight", :via => "get"
  match '/species/:species_id/birth_weights/:id' => 'birth_weights#destroy', :as => "destroy_birth_weight", :via => "delete"
  match '/species/:species_id/birth_weights' => 'birth_weights#create', :via => "post"
  match '/species/:species_id/birth_weights/:id' => 'birth_weights#update', :via => "put"
  match '/species/:species_id/litter_sizes/new' => 'litter_sizes#new', :as => "new_litter_size", :via => "get"
  match '/species/:species_id/litter_sizes/:id/edit' => 'litter_sizes#edit', :as => "edit_litter_size", :via => "get"
  match '/species/:species_id/litter_sizes/:id' => 'litter_sizes#destroy', :as => "destroy_litter_size", :via => "delete"
  match '/species/:species_id/litter_sizes' => 'litter_sizes#create', :via => "post"
  match '/species/:species_id/litter_sizes/:id' => 'litter_sizes#update', :via => "put"
  match '/:rank/:taxon' => 'taxa#index', :as => "taxon", :rank => /(kingdom|phylum|class|order|family)/, :via => "get"
  match '/taxa/data.:format' => 'taxa#data', :as => "data", :rank => /(kingdom|phylum|class|order|family)/, :via => "get"
  match '/taxonomy/dropdown/:rank' => 'taxa#dropdown_options', :as => "taxonomy_dropdown", :rank => /(kingdom|phylum|class|order|family)/, :via => "get"
  
  root :to => 'taxa#index'
end
