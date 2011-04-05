class Reference < ActiveRecord::Base
  has_many :taxa, :through => :citations
  
  def to_s
    string = ""
    string << "<a href=\"http://www.ncbi.nlm.nih.gov/pubmed?term=#{pubmed_id}\">" if pubmed_id
    
    string << "#{author}. " unless author.blank?
    string << "#{title}. "  unless title.blank?
    unless publisher.blank? || year.blank?
      string << "#{publisher}, #{year}. "
    else
      string << "#{publisher}. " unless publisher.blank?
      string << "#{year}. "      unless year.blank?
    end
    
    string << "</a>" if pubmed_id
    string
  end
end

# == Schema Information
#
# Table name: references
#
#  id         :integer         not null, primary key
#  title      :string(255)     not null
#  author     :string(255)
#  publisher  :string(255)
#  year       :string(255)
#  pubmed_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

