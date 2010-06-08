class User < ActiveRecord::Base
  acts_as_authentic
  include KarmaClient::User
  
  # The permalink to use to refer to this user in the karma server. Must be
  # implemented for the karma client to work.
  def karma_permalink
    # Escaping code is taken from the permalink_fu plugin.
    result = self.email.dup
    result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
    result.gsub!(/[^\w_ \-]+/i, '') # Remove unwanted chars.
    result.gsub!(/[ \-]+/i, '-') # No more than one of the separator in a row.
    result.gsub!(/^\-|\-$/i, '') # Remove leading/trailing separator.
    result.downcase!
    result    
  end
  
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

