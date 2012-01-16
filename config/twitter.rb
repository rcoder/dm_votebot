require 'yaml'
require 'twitter'

CREDENTIALS = YAML.load_file('config/credentials.yml')

Twitter.configure do |config|
  config.consumer_key = CREDENTIALS[:consumer_key]
  config.consumer_secret = CREDENTIALS[:consumer_secret]
  config.oauth_token = CREDENTIALS[:oauth_token]
  config.oauth_token_secret = CREDENTIALS[:oauth_secret]
end
