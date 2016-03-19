# Reddit API

A lightweight wrapper that is unobtrusive and intuitive to use.

Features:
  - Full OAuth support and token management
  - Multiple Users running in one script
  - Request throttling
  - Full API wrapper for all endpoints / objects
  - Automatic http retry

## Installation

install it as:

    $ gem install reddit-api

## Usage

Follow the Reddit API Guidelines:  https://github.com/reddit/reddit/wiki/API

First get a application token / secret for sign in from: https://www.reddit.com/prefs/apps


## Creating A User
We need a user:
```ruby
user = Reddit::Services::User.new "username", "password", "script_id", "script_secret", "User Agent Title"
```

## Retrieving Data
Getting back data is simple. Use The `Reddit::Services::*` Module and functions to retrieve data.
```ruby
user_info = Reddit::Services::Account.get_me user
```

Getting back a subreddit takes a bit more info.

```ruby
subreddit_posts = Reddit::Services::Listings.get_hot user, basepath_subreddit: "subreddit_name_without_r_slash", limit:50
```
note: anytime there is a `basepath_` variable the value is substituted into the URL with whatever is after the _ .In this case "basepath_subreddit" defines the "subreddit" part of the path.

note: to list the available fields prepend `print_` to any method call as shown for `get_hot` below.

```ruby
[1] pry(main)> subreddit_posts = Reddit::Services::Listings.print_get_hot                  
=> ["basepath_subreddit", "after", "before", "count", "limit", "show", "sr_detail"]
```

Getting back a comments requires multiple basepath substitutions.
```ruby
subreddit_comments = Reddit::Services::Listings.get_comments_article user, basepath_article:"article_id_from_permalink", basepath_subreddit: "subreddit_without_r_slash", limit:50
```
note: the two "basepath_" variables because the url requires not only a subreddit but a post ID in the basepath.

Debug Logging can be enabled or disabled at any time with:

## Retrieve Batches From Listing

The `Listings` group of endpoints have a helper method `batch_` that can be used in place of `get_`. Bath will make multiple calls to the endpoint and return the complete set.

A batch method must pass `page_size: #` and `max_size: #`
- `page_size` is the number of entries to request per call
- `max_size` is the maximum number of entries expected, batch may return before max_size is met because all entries have been retrieved.
- `remove_sticky` (default true, optional) removes entries that are stickied.  

```ruby
subreddit_all_posts = Reddit::Services::Listings.batch_new user, basepath_subreddit: "subreddit_name_without_r_slash", page_size:100, max_size:2000
```
note: There is API limitations that limits Listing endpoints to only cache the last 1000 entries and only allows a maximum of 100 entries per page.

## Logging

```ruby
Reddit::Internal::Logger.log.level = Log4r::DEBUG
```

Valid Log Levels are `DEBUG, INFO, WARN, ERROR, FATAL`

## Examples

A simple full example to retrieve a subreddit and gather the domains

```ruby
require "reddit/api"
# Sign In User, since we are just making a maximum of 10 calls throttling has been disabled.
user = Reddit::Services::User.new "username", "password", "script_id", "secret", "user-agent-title", request_throttle: false
# Retrieve Data
til_recent = Reddit::Services::Listings.batch_new user, basepath_subreddit: "todayilearned", page_size:100, max_size:500

# Process Results (Create a hash of domain -> # of posts)
posted_urls = {}
til_recent.each do |post|
  domain = post["data"]["url"].split("/")[2]
  posted_urls[domain] = 0 unless posted_urls.include?(domain)

  posted_urls[domain] += 1
end
# Delete One offs
posted_urls.reject! {|k,v| v < 2 }
# Display results
puts JSON.pretty_generate(posted_urls)
```

## One Offs

The endpoint for moderator messages is not defined in the API docs but can be found under:

```ruby
Reddit::Services::PrivateMessages.get_message_moderator user, basepath_subreddit: "worldnews"
```

## Contributing

To run rspec a file for configuring a user is required:

data/rspec_user.json
```json
{
  "user": "",
  "password": "",
  "service_id": "",
  "secret": ""
}
```
note: rspec will fail if the reddit service are unavaliable.

Bug reports and pull requests are welcome on GitHub at https://github.com/karl-b/reddit-api.
