require 'machinist'
require 'machinist/active_record'
require 'sham'

User.blueprint do
  email { Faker::Internet.email }
  password { 'secret' }
  password_confirmation { 'secret' }
end

Taxon.blueprint do
  name { Faker::Name.first_name }
  rank { (0..5).to_a.rand }
  lineage_ids ""
end

Species.blueprint do
  parent_id { Taxon.make(:rank => 5).id }
  name { Faker::Name.first_name }
  rank 6
end

Lifespan.blueprint do
  species
  value_in_days { rand }
  units   { %w(Days Months Years).rand }
end

AdultWeight.blueprint do
  species
  value_in_grams { rand }
  units   { %w(Grams Kilograms).rand }
end

BirthWeight.blueprint do
  species
  value_in_grams { rand }
  units   { %w(Grams Kilograms).rand }
end

LitterSize.blueprint do
  species
  measure { (0..12).to_a.rand }
end