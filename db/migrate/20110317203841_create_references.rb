class CreateReferences < ActiveRecord::Migration
  def self.up
    remove_column :adult_weights, :citation
    remove_column :adult_weights, :citation_context
    remove_column :birth_weights, :citation
    remove_column :birth_weights, :citation_context
    remove_column :lifespans, :citation
    remove_column :lifespans, :citation_context
    remove_column :litter_sizes, :citation
    remove_column :litter_sizes, :citation_context
    
    create_table :references, :force => true do |t|
      t.string  :title, :null => false
      t.string  :author, :publisher, :year
      t.integer :pubmed_id
      t.timestamps
    end
    
    create_table :citations, :force => true do |t|
      t.integer :reference_id, :taxon_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :citations
    drop_table :references
    add_column :litter_sizes, :citation_context, :text
    add_column :litter_sizes, :citation, :string
    add_column :lifespans, :citation_context, :text
    add_column :lifespans, :citation, :string
    add_column :birth_weights, :citation_context, :text
    add_column :birth_weights, :citation, :string
    add_column :adult_weights, :citation_context, :text
    add_column :adult_weights, :citation, :string
  end
end