# MagentoRestApi

This Gem will enable you to communicate to the rest api of magento 1.9.x
Beware of the limitations of the ruby 1.9.x restfull service.
The Soap service is much more extensive.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'magento_rest_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install magento_rest_api

## Usage

You first need to authenticate this app to your magento by running the command
```sh
% authenticate
```

Use the above information to connect to the rest api after this you can do a get post put request.
GET request (get product information):

```irb
% irb
   >> require 'restfull_oauth'
   >> service = MagentoRestApi::Connection.new({"consumer_key"=>"your_consumer_key", "consumer_secret"=>"your_consumer_secret", "token"=>"your_token", "token_secret"=>"your_token_secret"})
   >> response = service.connect('GET','https://your magento/api/rest/products', keys)
   => #<Net::HTTPOK 200 OK readbody=true>
   >> puts JSON.parse(response.body).to_yaml
```

POST request (assign product to website):

```irb
% irb
   >> require 'restfull_oauth'
   >> service = MagentoRestApi::Connection.new({"consumer_key"=>"your_consumer_key", "consumer_secret"=>"your_consumer_secret", "token"=>"your_token", "token_secret"=>"your_token_secret"})
   >> post_data = {'foo' => 'bar' }.to_json
   >> response = RestfullOauth::connect('POST','https://your magento/api/rest/products/200/websites', post_data)
   => #<Net::HTTPOK 200 OK readbody=true>
   >> puts JSON.parse(response.body).to_yaml
```

PUT requests work in the same way as POST requests

more information about magento's REST API: http://devdocs.magento.com/guides/m1x/api/rest/introduction.html
I cannot stress enough to first find out if the API provides enough information for you.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Daniel304/magento_rest_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

