# Fixturex [![Ruby](https://github.com/artemave/fixturex/actions/workflows/ruby.yml/badge.svg)](https://github.com/artemave/fixturex/actions/workflows/ruby.yml)

Rails fixtures explorer.

## Description

Rails fixtures are hard work. There are different sides to that, but one particular thing is that it's not obvious what other fixtures reference the one you're looking at and what fixtures reference those ones referencing the one you're looking at. And so on.

This little gem to the rescue. It's a command line tool that shows reference tree for a given fixture. It plugs in to vim's quickfix and it shouldn't be much work to plug it into vscode, if anyone is up for it.

<details>
  <summary>Demo</summary>
    
https://user-images.githubusercontent.com/23721/135531049-527640b0-f2f9-436b-923d-c5fc4d9f3fe8.mp4

</details>


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fixturex'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fixturex

## Usage

    $ bundle exec fixturex test/fixtures/things.yml thing1

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/featurist/fixturex.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
