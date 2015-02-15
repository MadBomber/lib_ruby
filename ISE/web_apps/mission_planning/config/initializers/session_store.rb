# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_MissionPlanning_session',
  :secret      => 'b22cae90a6fcc781b4f011ffd39ec8cad7b81918ef95f10c44f505a828b142e56c3882d0a19bf26515811a40f8d9ef943e2c7ebf7c67b59343aa4d372350be1d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
