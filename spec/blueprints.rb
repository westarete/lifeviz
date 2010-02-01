require 'machinist'
require "machinist/active_record"

Sham.define do

end

Taxon.blueprint do
  
end

Species.blueprint do
  
end

Lifespan.blueprint do
  species
  
end
