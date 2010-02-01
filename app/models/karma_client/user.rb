module KarmaClient
  module User
  
    # Provide access to the user's karma.
    def karma
      Karma.new(self)
    end

  end  
end
