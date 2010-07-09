class CreateCitations < ActiveRecord::Migration
  def self.up
    [:lifespans, :birth_weights, :adult_weights, :litter_sizes].each do |table_name|
      add_column table_name, :citation, :string
      add_column table_name, :citation_context, :text
    end
  end

  def self.down
    [:lifespans, :birth_weights, :adult_weights, :litter_sizes].each do |table_name|
      remove_column table_name, :citation_context
      remove_column table_name, :citation
    end
  end
end
