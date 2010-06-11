module KarmaClient
  class Tags
    
    # Accepts a hash of tag names (symbols) and tag values.
    def initialize(tags)
      # We intentionally do not dup the hash that we are given. We actually
      # want this to be the same hash object that the karma object has, so
      # that our changes here are reflected in the total there.
      @tags = tags
      define_tag_getter_methods
      define_tag_setter_methods
    end
    
    # Return the sum of all tag totals. Most people shouldn't use this
    # directly. Use @user.karma.total instead.
    def _total  # :nodoc:
      total = 0
      @tags.each do |name, hash|
        total += hash['total']
      end
      total
    end
    
    private
    
    # Define the getter accessor methods for the tags.
    def define_tag_getter_methods
      @tags.keys.each do |tag_name|
        next if respond_to? tag_name
        if tag_name =~ /karma:(.*)/
          class_eval %{
            def karma
              def #{$1}
                @tags['#{tag_name}']['total']
              end
            end
          }    
        else
          class_eval %{
            def #{tag_name}
              @tags['#{tag_name}']['total']
            end
          }
        end    
      end
    end

    # Define the setter accessor methods for the tags.
    def define_tag_setter_methods
      @tags.keys.each do |tag_name|
        next if respond_to? :"#{tag_name}="
        if tag_name =~ /karma:(.*)/
          class_eval %{
            def karma
              def #{$1}=(new_value)
                update_tag_value('#{tag_name}', new_value)
              end
            end
          }
        else
          class_eval %{
            def #{tag_name}=(new_value)
              update_tag_value('#{tag_name}', new_value)
            end
          }
        end 
      end
    end
    
    # Update the given tag name with the new value, and notify the karma
    # server.
    def update_tag_value(tag_name, new_value)
      adjustment_value = new_value - @tags[tag_name]['total']
      send_adjustment_to_karma_server(tag_name, adjustment_value)
      @tags[tag_name]['total'] = new_value
    end
        
    # Send an update to the karma server that adjusts the given tag by
    # the given amount.
    def send_adjustment_to_karma_server(tag_name, adjustment_value)
      resource = RestClient::Resource.new("http://#{KARMA_SERVER_HOSTNAME}#{@tags[tag_name]['adjustments_path']}", "", KARMA_API_KEY)
      resource.post("adjustment[value]=#{adjustment_value}")
    rescue RestClient::Exception => e
      # TODO: What is the appropriate behavior when this request fails?
      p e.response
      raise
    end
    
  end
end