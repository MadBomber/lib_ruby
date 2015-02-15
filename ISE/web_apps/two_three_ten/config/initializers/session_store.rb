# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_two_three_ten_session',
  :secret      => 'eb6572a579f81a874f381aa8aadaf1a01835345e943fbc28e5ce71c57bdff24eba6b297763d28d9e35dbd6bd766b1868425fb2c8afe9739e17be118f4fa209ea'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
