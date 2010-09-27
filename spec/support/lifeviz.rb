def log_in
  visit root_path
  fill_in 'user_email', :with => user.email
  fill_in 'user_password', :with => "secret"
  click 'Login'
end

def make_biological_classification(rank = 5)
  return false if rank < -1 || 5 < rank
  Taxon.find_by_rank(rank) ? make_biological_classification(rank - 1) : Taxon.create(:rank => rank.to_i, :parent_id => make_biological_classification(rank - 1), :name => Faker::Name.first_name).id
end