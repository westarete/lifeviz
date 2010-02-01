class User < ActiveRecord::Base
  acts_as_authentic
end

# == Schema Information
#
# Table name: users
#
#  id                :integer         not null, primary key
#  email             :string(255)
#  crypted_password  :string(255)
#  password_salt     :string(255)
#  persistence_token :string(255)     not null
#  created_at        :datetime
#  updated_at        :datetime
#  openid_identifier :string(255)
#

