require 'yaml'
require 'oauth'
require 'twitter'
require 'highline/import'

TWITTER_CONFIG = YAML.load_file('config/api.yml')
CREDENTIAL_FILE = 'config/credentials.yml'
LIST_MEMBERS_FILE = 'config/members.yml'

$LOAD_PATH << Dir.pwd

task :default => :'dm:fetch'

file CREDENTIAL_FILE do
  key = ask('OAuth key: ') {|q| q.echo = '*' }
  secret = ask('OAuth secret: ') {|q| q.echo = '*' }
  consumer = OAuth::Consumer.new(key, secret, TWITTER_CONFIG)
  request_token = consumer.get_request_token

  `open #{request_token.authorize_url}`
  pin_code = ask('Enter the OAuth PIN: ') {|q| q.echo = '*' }
  access_token = request_token.get_access_token(:oauth_verifier => pin_code)

  open(CREDENTIAL_FILE, 'w') do |fh| 
    YAML.dump({
      :consumer_key => key.to_s,
      :consumer_secret => secret.to_s,
      :oauth_token => access_token.token,
      :oauth_secret => access_token.secret
    }, fh)
  end

  puts "Saved OAuth credentials to #{CREDENTIAL_FILE}."
end

task :configure do
  require 'config/twitter'
end

file LIST_MEMBERS_FILE do
  list_user = ask('List owner: ')
  list_name = ask('List name: ')
  all_members = []
  next_cursor = -1
  begin
    member_page = Twitter.list_members(list_user, list_name, :cursor => next_cursor)
    all_members += member_page.collection
    puts "Fetched page #{next_cursor}"
    next_cursor = member_page.next_cursor
  end while !member_page.last?
  open(LIST_MEMBERS_FILE, 'w') {|fh| YAML.dump(all_members, fh) }
end

namespace :dm do
  task :fetch do
    puts YAML.dump(Twitter.direct_messages)
  end
end

task :configure => CREDENTIAL_FILE
file LIST_MEMBERS_FILE => :configure
task :'dm:fetch' => LIST_MEMBERS_FILE
