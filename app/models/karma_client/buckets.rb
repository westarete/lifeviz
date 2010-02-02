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
    
    # Return the sum of all bucket totals. Most people shouldn't use this
    # directly. Use @user.karma.total instead.
    def _total  # :nodoc:
      total = 0
      @buckets.each do |name, hash|
        total += hash['total']
      end
      total
    end
    
    private
    
    # Define the getter accessor methods for the buckets.
    def define_bucket_getter_methods
      @buckets.keys.each do |bucket_name|
        next if respond_to? bucket_name
        class_eval %{
          def #{bucket_name}
            @buckets['#{bucket_name}']['total']
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
            update_bucket_value('#{bucket_name}', new_value)
          end
        }        
      end
    end
    
    # Update the given bucket name with the new value, and notify the karma
    # server.
    def update_bucket_value(bucket_name, new_value)
      adjustment_value = new_value - @buckets[bucket_name]['total']
      send_adjustment_to_karma_server(bucket_name, adjustment_value)
      @buckets[bucket_name]['total'] = new_value
    end
        
    # Send an update to the karma server that adjusts the given bucket by
    # the given amount.
    def send_adjustment_to_karma_server(bucket_name, adjustment_value)
      resource = RestClient::Resource.new("http://#{KARMA_SERVER_HOSTNAME}#{@buckets[bucket_name]['adjustments_path']}")
      resource.post("adjustment[value]=#{adjustment_value}")
    rescue RestClient::Exception => e
      # TODO: What is the appropriate behavior when this request fails?
      p e.response
      raise
    end
    
  end
end