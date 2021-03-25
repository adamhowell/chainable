Chainable is a Ruby gem to track consecutive day chains on your Rails/ActiveRecord models. Hard fork of [streakable](https://github.com/szTheory/streakable) by szTheory. Renamed it because was having namespace issues with my project Streaky

## Installation

Add this line to your application's Gemfile:

    gem 'chainable'

And then execute:

    $ bundle

Or install it directly with:

    $ gem install chainable

## Usage

Let's say I have a <code>User</code> that <code>has_many</code> posts:

```ruby
class User < ActiveRecord::Base
  has_many :posts
end
```

I want to track how many days in a row that each user wrote a post. I just have to include <code>chainable</code> in the model:

```ruby
class User < ActiveRecord::Base
  include chainable
end
```

Now I can display the user's chain:

```ruby
user.chain(:posts) # => number of days in a row that this user wrote a post (as determined by the created_at column, by default)
```

The <code>chain</code> instance method can be called with any association:

```ruby
user.chain(:other_association)
```

And you can change the column the chain is calculated on:

```ruby
user.chain(:posts, :updated_at)
```

Don't penalize the current day being absent when determining chains (the User could write another Post before the day ends):

```ruby
user.chain(:posts, except_today: true)
```

Find the longest chain, not just the current one:

```ruby
user.chain(:posts, longest: true)
```

To get all of the chains, not just the current one:

```ruby
user.chains(:posts)
```

## TODO

* Add class methods/scopes for calculating chains on records not in memory

## Specs
To run the specs for the currently running Ruby version, run `bundle install` and then `bundle exec rspec`. To run specs for every supported version of ActionPack, run `bundle exec appraisal install` and then `bundle exec appraisal rspec`.

## Gem release
Make sure the specs pass, bump the version number in chainable.gemspec, build the gem with `gem build chainable.gemspec`. Commit your changes and push to Github, then tag the commit with the current release number using Github's Releases interface (use the format vx.x.x, where x is the semantic version number). You can pull the latest tags to your local repo with `git pull --tags`. Finally, push the gem with `gem push chainable-version-number-here.gem`.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`) or bugfix branch (`git checkout -b bugfix/my-helpful-bugfix`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Make sure specs are passing (`bundle exec rspec`)
6. Create new Pull Request

## License

See the [LICENSE](https://github.com/szTheory/chainable/blob/master/LICENSE.txt) file.