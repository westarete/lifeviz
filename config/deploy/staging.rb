
# The directory that we're deploying to on the remote host.
set :deploy_to, "/var/www/domains/anage.staging.westarete.com"

# Tell capistrano to use the staging environment. This is key for running 
# the database migrations via "cap staging deploy:migrations".
set :rails_env, "staging"

# Non-standard ssh port.
ssh_options[:port] = 22222

# The hosts that we're deploying to.
role :app, "staging.westarete.com"
role :web, "staging.westarete.com"
role :db,  "staging.westarete.com", :primary => true
