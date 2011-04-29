require 'lib/monkeypatches'
require 'db/seed_methods'
include SeedMethods

class Taxon < ActiveRecord::Base
  acts_as_nested_set
  
  named_scope :kingdoms, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 0}.merge(conditions), :order => :name} }
  named_scope :phylums,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 1}.merge(conditions), :order => :name} }
  named_scope :classes,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 2}.merge(conditions), :order => :name} }
  named_scope :orders,   lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 3}.merge(conditions), :order => :name} }
  named_scope :families, lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 4}.merge(conditions), :order => :name} }
  named_scope :genuses,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 5}.merge(conditions), :order => :name} }
  named_scope :species,  lambda { |conditions| conditions ||= {}; {:conditions => {:rank => 6}.merge(conditions), :order => :name} }
  
  has_one :statistics, :dependent => :destroy
  has_many :citations
  has_many :references, :through => :citations
  
  validates_presence_of :rank, :message => "must be set"
  validates_presence_of :name, :message => "can't be blank"
  
  RANK_LABELS = %w(Kingdom Phylum Class Order Family Genus Species)
  
  after_create :create_statistics_object
  
  def statistics
    Statistics.find_by_taxon_id(self.id)
  rescue
    Statistics.new
  end
  
  # This method rebuilds lineage_ids for the entire taxonomy.
  # TODO: I haven't actually tried this code yet, because it still takes a while
  # to run! If you run it successfully, remove this TODO, please!
  def self.rebuild_lineages!
    logger.info "Creating kingdom lineage ids"
    self.connection.execute "
    update taxa
      set lineage_ids = 1
      where rank = 0;"
    
    %w(phylum class order family genus species).each_with_index do |name, i|
      logger.info "Creating #{name} lineage ids"
      self.connection.execute "
      update taxa
        set lineage_ids = parent.lineage_ids || ',' || taxa.id
        from taxa parent
        where
          taxa.rank = #{i + 1}
          and taxa.parent_id = parent.id;"
    end
  end
  
  def self.taxa_ids_with_data
    heirarchies = Taxon.find(Species.species_ids_with_data).collect do |species|
      species.hierarchy
    end
    heirarchies.flatten.uniq.sort
  end
  
  def self.rebuild_stats
    # Species.rebuild_stats
    taxa_ids = Taxon.taxa_ids_with_data
    progress "Statistics", taxa_ids.length do |progress_bar|
      Taxon.find(taxa_ids).each do |taxon|
        taxon.calculate_statistics
        progress_bar.inc
      end
    end
    
    #   size = Taxon.count(:all, :conditions => {:rank => rank})
    #   progress "#{RANK_LABELS[rank]}", size do |progress_bar|
    #     Taxon.find(:all, :conditions => {:rank => rank} ).each do |taxon|
    #       taxon.calculate_statistics
    #       progress_bar.inc
    #     end
    #   end
    #   rank -= 1
    # end
  end
  
  # Redefining our own 'root' method, which should run much faster...
  def self.root
    find(1)
  end
  
  def self.find_by_name_and_rank(name, rank)
    rank_match = RANK_LABELS.find { |l| l.downcase == rank.downcase }
    rank_match_index = RANK_LABELS.index(rank_match)
    self.find(:first, :conditions => {:name => name.capitalize, :rank => rank_match_index})
  end
  
  def all_data_available?
    # this used to have be_close clauses, but they stopped working because Statistics now returns strings instead of floats
    not (self.statistics.average_lifespan.blank? or 
         self.statistics.average_birth_weight.blank? or 
         self.statistics.average_adult_weight.blank? or
         self.statistics.average_litter_size.blank? )
  end
  
  def parents
    Taxon.find(hierarchy, :order => 'rank ASC')
  end
  
  def children_of_rank(rank)
    if rank && self.rank < rank
      rank = 6 if rank > 6
      Species.find_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = #{rank} ORDER BY name ASC")
    else
      raise 'rank not set properly'
    end
  end
  
  # returns an array of arrays. 
  # full_ancestry[0] is an array of the ancestors at rank 0
  # full_ancestry[1] is an array of the ancestors at rank 1, etc
  def full_ancestry(options = {})
    options = {:include_children => false}.merge(options)
    hierarchy_array = self.hierarchy
    hierarchy_array << 1 # for the top-level, rank0 terms
    hierarchy_array << self.id if options[:include_children]
    ancestry = self.class.find_all_by_parent_id(hierarchy_array, :order => 'rank asc, name asc')
    # Makes our 1D array into a 2D array
    returning Array.new do |ranked_ancestry|
      ancestry.each do |term|
        rank = term.rank.to_i
        ranked_ancestry[rank] ||= []
        ranked_ancestry[rank] << term
      end
    end
  end
  
  def hierarchy
    if self.lineage_ids.nil?
      []
    else
      self.lineage_ids.split(',').map{|id| id.to_i}
    end
  end
  
  def paginated_sorted_species(page)
    begin
      Species.paginate_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = 6 ORDER BY name ASC", :page => page)
    rescue
      raise "Left and Right attributes were nil!"
    end
  end
  
  def rank_in_words
    RANK_LABELS[self.rank.to_i]
  end
  
  def scientific_name
    (id == 1) ? 'All Taxa' : read_attribute(:name)
  end
  
  def species
    begin
      @species = Species.find_by_sql("SELECT * FROM taxa WHERE lft >= #{self.lft} AND rgt <= #{self.rgt} AND rank = 6 ORDER BY name ASC")
    rescue
      raise "Left and Right attributes were nil!"
    end
  end
  
  def calculate_statistics
    time = Benchmark.realtime do
    result = connection.execute "
      SELECT 
        MIN(lifespans.value_in_days) as minimum_lifespan,
        MAX(lifespans.value_in_days) as maximum_lifespan,
        AVG(lifespans.value_in_days) as average_lifespan,
        STDDEV(lifespans.value_in_days) as standard_deviation_lifespan,
        MIN(litter_sizes.value) as minimum_litter_size,
        MAX(litter_sizes.value) as maximum_litter_size,
        AVG(litter_sizes.value) as average_litter_size,
        STDDEV(litter_sizes.value) as standard_deviation_litter_size,
        MIN(adult_weights.value_in_grams) as minimum_adult_weight,
        MAX(adult_weights.value_in_grams) as maximum_adult_weight,
        AVG(adult_weights.value_in_grams) as average_adult_weight,
        STDDEV(adult_weights.value_in_grams) as standard_deviation_adult_weight,
        MIN(birth_weights.value_in_grams) as minimum_birth_weight,
        MAX(birth_weights.value_in_grams) as maximum_birth_weight,
        AVG(birth_weights.value_in_grams) as average_birth_weight,
        STDDEV(birth_weights.value_in_grams) as standard_deviation_birth_weight
      FROM taxa
      LEFT OUTER JOIN lifespans
        ON taxa.id = lifespans.species_id
      LEFT OUTER JOIN litter_sizes
        ON taxa.id = litter_sizes.species_id
      LEFT OUTER JOIN adult_weights
        ON taxa.id =  adult_weights.species_id
      LEFT OUTER JOIN birth_weights
        ON taxa.id =  birth_weights.species_id
      WHERE
        taxa.lft >= #{lft} AND
        taxa.rgt <= #{rgt}
    "
    statistics = nil
    ["minimum_lifespan",     "maximum_lifespan",     "average_lifespan",     "standard_deviation_lifespan",
     "minimum_adult_weight", "maximum_adult_weight", "average_adult_weight", "standard_deviation_adult_weight",
     "minimum_birth_weight", "maximum_birth_weight", "average_birth_weight", "standard_deviation_birth_weight",
     "minimum_litter_size",  "maximum_litter_size",  "average_litter_size",  "standard_deviation_litter_size"
    ].each do |column_name|
      if result[0][column_name] && ! result[0][column_name].empty?
        statistics ||= Statistics.find_or_create_by_taxon_id(id)
        statistics[column_name] = result[0][column_name].to_f
      end
    end
    
    statistics.save! if statistics
    end
    time_elapsed = "%.1f" % [time*1000]
    print "   #{time_elapsed}MS-#{self.rank}-#{self.name}\r"
  end
  
  private
  
  def create_statistics_object
    Rails.logger.info "Creating statistics for taxon #{self.id}"
    self.create_statistics
  end
  
end

# == Schema Information
#
# Table name: taxa
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  parent_id   :integer
#  lft         :integer
#  rgt         :integer
#  rank        :integer
#  lineage_ids :string(255)
#

