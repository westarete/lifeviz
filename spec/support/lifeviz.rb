def log_in(user)
  visit root_path
  click 'Log in'
  fill_in 'user_email', :with => user.email
  fill_in 'user_password', :with => "password"
  click 'Login'
end

def make_biological_classification(rank = 5)
  return false if rank < -1 || 5 < rank
  Taxon.find_by_rank(rank) ? make_biological_classification(rank - 1) : Taxon.create(:rank => rank.to_i, :parent_id => make_biological_classification(rank - 1), :name => Faker::Name.first_name).id
end