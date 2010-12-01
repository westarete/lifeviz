# NOTE: selenium is required to run log_in
def log_in(user)
  visit root_path
  if page.has_content?("Log out")
    click_link "Log out"
  end
  click 'Log in'
  fill_in 'user_email'    ,:with => user.email
  fill_in 'user_password' ,:with => "password"
  click 'Login'
end

def make_biological_classification(rank = 5)
  return false if rank < -1 || 5 < rank
  if Taxon.find_by_rank(rank) 
    make_biological_classification(rank - 1)
  else
    parent_id = make_biological_classification(rank - 1)
    taxon = Taxon.new
    taxon.rank = rank.to_i
    taxon.parent_id = parent_id
    taxon.lineage_ids = (parent_id == false ? "1" : Taxon.find(parent_id).lineage_ids+",#{parent_id+1}")
    taxon.name = Faker::Name.first_name
    taxon.save!
    return taxon.id
  end
end

def make_statistics_set
  @taxon    = Taxon.make(:rank => 5)
  @species1 = Species.make(:parent_id => @taxon.id)
  @species2 = Species.make(:parent_id => @taxon.id)
  Taxon.rebuild_statistics_objects
  
  @species1.litter_sizes.create!(:value => 10)
  @species1.litter_sizes.create!(:value => 20)
  @species2.litter_sizes.create!(:value => 30)
  @species2.litter_sizes.create!(:value => 40)
  @species1.birth_weights.create!(:value_in_grams => 10, :units => "Grams")
  @species1.birth_weights.create!(:value_in_grams => 20, :units => "Grams")
  @species2.birth_weights.create!(:value_in_grams => 30, :units => "Grams")
  @species2.birth_weights.create!(:value_in_grams => 40, :units => "Grams")
  @species1.adult_weights.create!(:value_in_grams => 10, :units => "Grams")
  @species1.adult_weights.create!(:value_in_grams => 20, :units => "Grams")
  @species2.adult_weights.create!(:value_in_grams => 30, :units => "Grams")
  @species2.adult_weights.create!(:value_in_grams => 40, :units => "Grams")
  @species1.lifespans.create!(:units => "Days", :value_in_days => 10)
  @species1.lifespans.create!(:units => "Days", :value_in_days => 20)
  @species2.lifespans.create!(:units => "Days", :value_in_days => 30)
  @species2.lifespans.create!(:units => "Days", :value_in_days => 40)
  
  # Set lft and rgt values for every taxon. Necessary!
  Taxon.rebuild!
end
