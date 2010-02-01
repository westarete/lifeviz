module Karma
  module User
  
    # Provide access to the user's karma.
    def karma
      Proxy.new(self)
    end

  end  
end
