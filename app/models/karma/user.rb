module Karma
  module User
  
    # Escape the given string to turn it into a permalink. Taken from the
    # permalink_fu plugin.
    def escape(string)
      result = string.dup.to_s
      result.gsub!(/[^\x00-\x7F]+/, '') # Remove anything non-ASCII entirely (e.g. diacritics).
      result.gsub!(/[^\w_ \-]+/i, '') # Remove unwanted chars.
      result.gsub!(/[ \-]+/i, '-') # No more than one of the separator in a row.
      result.gsub!(/^\-|\-$/i, '') # Remove leading/trailing separator.
      result.downcase!
      result
    rescue
      nil
    end
  
    def permalink
      escape(email)
    end
  
    # The resource for fetching this user's karma.
    def karma_url
      "http://#{KARMA_SERVER_HOSTNAME}/users/#{permalink}/karma.json"
    end
  
    # Return the karma for this user.
    def karma
      return @karma if defined? @karma
      # resource = RestClient::Resource.new(karma_url, :user => '', :password => KARMA_API_KEY)   # with authentication
      resource = RestClient::Resource.new(karma_url)
      json = resource.get
      results = ActiveSupport::JSON.decode(json)
      @karma = results['total']
    rescue RestClient::Exception
      # TODO: What is the appropriate behavior when the karma server is unreachable?
      nil 
    end
  
    # Returns true if the user has attained a "bronze" karma level.
    def bronze?
      karma >= 5
    end
  
    # Returns true if the user has attained a "silver" karma level.
    def silver?
      karma >= 10
    end
  
    # Returns true if the user has attained a "gold" karma level.
    def gold?
      karma >= 20
    end

  end  
end
