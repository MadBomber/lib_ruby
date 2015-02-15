# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_NewEngagementManager_session',
  :secret      => '681b664d4366c6f455a44615b8ca10c2fcc99a3a6835f8967da7b228a1012b0a157fce514ddaeefad807b4f388a6265cb9760ddc3c908f919ef8ae80062de06a'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
