# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_anage_session',
  :secret      => 'e84df2a4b5096ce79cbb5967853f177ed0e5a44737d52e6af9f3968540499bd8a738a17c5f6e23b7eddcf61547d70a306b25a1129af65efded6693bfd5210603'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
