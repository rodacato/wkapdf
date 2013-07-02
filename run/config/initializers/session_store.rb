# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_run_session',
  :secret      => 'd9040f80d7b2fdf1bd82f1bdb398bcc9a1c7f895b5b853056422201261c5792e2ecfd4c4451d7d351313875541312944af0b9afca2897bcdec808854631a6818'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
