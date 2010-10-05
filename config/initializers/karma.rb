if RAILS_ENV == 'test' || RAILS_ENV == 'development' || RAILS_ENV == 'full_set'
  KARMA_SERVER_HOSTNAME = 'localhost:4000'
  KARMA_API_KEY = '1cc05149bd2ab581087b820c336a8ffc'
else
  KARMA_SERVER_HOSTNAME = 'karma.beta.westarete.com'
  KARMA_API_KEY = '3c363701e83ee4a5164bf73b242bfbf9'
end
