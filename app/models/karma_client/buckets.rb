module KarmaClient
  class Buckets
    
    # Accepts a hash of bucket names (symbols) and bucket values.
    def initialize(buckets)
      # We intentionally do not dup the hash that we are given. We actually
      # want this to be the same hash object that the karma object has, so
      # that our changes here are reflected in the total there.
      @buckets = buckets
      define_bucket_getter_methods
      define_bucket_setter_methods
    end
    
    private
    
    # Define the getter accessor methods for the buckets.
    def define_bucket_getter_methods
      @buckets.keys.each do |bucket_name|
        next if respond_to? bucket_name
        class_eval %{
          def #{bucket_name}
            @buckets[:#{bucket_name}]
          end
        }        
      end
    end

    # Define the setter accessor methods for the buckets.
    def define_bucket_setter_methods
      @buckets.keys.each do |bucket_name|
        next if respond_to? :"#{bucket_name}="
        class_eval %{
          def #{bucket_name}=(new_value)
            @buckets[:#{bucket_name}] = new_value
          end
        }        
      end
    end
    
  end
end