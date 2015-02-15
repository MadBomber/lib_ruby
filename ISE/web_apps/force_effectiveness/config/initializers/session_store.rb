# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ForceEffectiveness_session',
  :secret      => '938a57f68faef3334bd510643fb048c2fa14f20fe50157af7d6f1f08397f9063e06e142b93ba5d15742f25742de60fcd88d6996183ed18aa63965b7a33d756aa'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
