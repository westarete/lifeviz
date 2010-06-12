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
  name { Faker::Name.first_name }
  rank 6
end

AdultWeight.blueprint do
  species
  measure { rand }
end

LitterSize.blueprint do
  species
  measure { (0..12).to_a.rand }
end