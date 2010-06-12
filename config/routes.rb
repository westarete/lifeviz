ActionController::Routing::Routes.draw do |map|
  map.resource  :user_session
  map.resources :users
  
  map.resources :species, :collection => { :data => :get }
  map.with_options :controller => :lifespans do |a|
    a.new_lifespan '/species/:species_id/lifespans/new', :action => :new, :conditions => {:method => :get}
    a.edit_lifespan '/species/:species_id/lifespans/:id/edit', :action => :edit, :conditions => {:method => :get}
    a.connect '/species/:species_id/lifespans', :action => :create, :conditions => {:method => :post}
    a.connect '/species/:species_id/lifespans/:id', :action => :update, :conditions => {:method => :put}
  end
  
  map.with_options :controller => :adult_weights do |i|
    i.new_adult_weight     '/species/:species_id/adult_weights/new'      ,:action => :new    ,:conditions => {:method => :get   }
    i.edit_adult_weight    '/species/:species_id/adult_weights/:id/edit' ,:action => :edit   ,:conditions => {:method => :get   }
    i.destroy_adult_weight '/species/:species_id/adult_weights/:id'      ,:action => :destroy,:conditions => {:method => :delete}
    i.connect '/species/:species_id/adult_weights'          ,:action => :create ,:conditions => {:method => :post   }
    i.connect '/species/:species_id/adult_weights/:id'      ,:action => :update ,:conditions => {:method => :put    }
  end
  
  map.with_options :controller => :litter_sizes do |i|
    i.new_litter_size     '/species/:species_id/litter_sizes/new'     ,:action => :new    ,:conditions => {:method => :get }
    i.edit_litter_size    '/species/:species_id/litter_sizes/:id/edit',:action => :edit   ,:conditions => {:method => :get }
    i.destroy_litter_size '/species/:species_id/litter_sizes/:id'     ,:action => :destroy,:conditions => {:method => :delete}
    i.connect '/species/:species_id/litter_sizes'     ,:action => :create ,:conditions => {:method => :post }
    i.connect '/species/:species_id/litter_sizes/:id' ,:action => :update ,:conditions => {:method => :put  }
  end
  
  # AJAX Navigation
  map.taxonomy_dropdown '/taxonomy/dropdown/:rank', 
    :controller => :taxonomy_navigation, 
    :action => :dropdown_options, 
    :rank => /(kingdoms|phylums|classes|orders|families|genuses|species)/,
    :conditions => {:method => :get}
  
  map.taxon '/:rank/:taxon',
    :controller => :species,
    :action => :index,
    :rank => /(kingdom|phylum|class|order|family|genus)/,
    :conditions => {:method => :get}
  
  map.root :controller => :species
end
