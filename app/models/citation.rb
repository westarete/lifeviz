class Citation < ActiveRecord::Base
  belongs_to :reference
  belongs_to :taxon
end

# == Schema Information
#
# Table name: citations
#
#  id           :integer         not null, primary key
#  reference_id :integer         not null
#  taxon_id     :integer         not null
#  created_at   :datetime
#  updated_at   :datetime
#

