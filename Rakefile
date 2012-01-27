require 'yaml'
require 'time'
require 'set'

$KCODE = 'UTF8'

require 'oauth'
require 'twitter'
require 'twitter-text'
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
  member_page = Twitter.list_members(list_user, list_name)
  all_members = [member_page.users.map {|u| u.id }]
  begin
    next_cursor = member_page.next_cursor
    member_page = Twitter.list_members(list_user, list_name, :cursor => next_cursor)
    all_members += member_page.users.map {|u| u.id }
  end while !(member_page.last? || next_cursor == 0)
  open(LIST_MEMBERS_FILE, 'w') {|fh| YAML.dump(all_members, fh) }
end

namespace :dm do
  task :fetch do
    authorized_users = Set[*YAML.load_file(LIST_MEMBERS_FILE)]

    messages = []
    seen_messages = Set.new
    message_page = Twitter.direct_messages

    while true
      message_page = message_page.select do |msg|
        authorized_users.member?(msg.sender.id) && !seen_messages.member?(msg.id)
      end

      message_page.each do |msg|
        seen_messages << msg.id
        messages << msg
      end

      break if message_page.empty?

      max_id = message_page.collect {|msg| msg.id }.last
      message_page = Twitter.direct_messages(:max_id => max_id, :count => 200)
    end

    votes = {}
    votes_by_user = Set.new

    messages.each do |msg|
      features = []
      #Twitter::Extractor.extract_mentioned_screen_names(msg.text).each {|str| features << "@#{str}" }
      Twitter::Extractor.extract_hashtags(msg.text).each {|str| features << "##{str.downcase}" }
      features.each do |f|
        full_key = "#{msg.sender.id}:#{f}"
        unless votes_by_user.member?(full_key)
          votes[f] = (votes[f] || 0) + 1
          votes_by_user << full_key
        end
      end
    end

    votes.keys.each do |k|
      puts "#{k},#{votes[k]}"
    end
  end
end

task :configure => CREDENTIAL_FILE
file LIST_MEMBERS_FILE => :configure
task :'dm:fetch' => LIST_MEMBERS_FILE
