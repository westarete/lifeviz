require 'machinist'
require 'machinist/active_record'
require 'sham'

User.blueprint do
  email { Faker::Internet.email }
  password { 'secret' }
  password_confirmation { 'secret' }
end
