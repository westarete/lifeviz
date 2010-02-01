module KarmaClient
  class Buckets
    
    # Accepts a hash of bucket names (symbols) and bucket values.
    def initialize(buckets)
      @buckets = buckets
      define_bucket_getter_methods
    end
    
    private
    
    # Define the accessor methods for the buckets.
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
    
  end
end