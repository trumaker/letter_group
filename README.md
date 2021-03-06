# LetterGroup

Organize data results from raw sql queries (as with PGresult, or Dossier) intelligently.  Or even simple arrays of hashes.

See specs for examples.

No view code yet, for now just the logic.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'letter_group'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install letter_group

## Usage

Here's a silly example.  You did a raw SQL query and don't know how to see the result, and somehow Google isn't working right now (!):

```
[1] pry(main)> ActiveRecord::Base.connection.execute("select localtimestamp at time zone 'UTC'")
   (1.9ms)  select localtimestamp at time zone 'UTC'
=> #<PG::Result:0x007fbde1b9b170 @connection=#<PG::Connection:0x007fbdfa9aee70 @notice_processor=nil, @notice_receiver=nil, @socket_io=nil>>
```

Oh Noes!  `LetterGroup::Group` is a can opener.  Use it.

```
[9] pry(main)> LetterGroup::Group.new(ActiveRecord::Base.connection.execute("select localtimestamp at time zone 'UTC'")).rows
   (0.5ms)  select localtimestamp at time zone 'UTC'
=> {nil=>[{"timezone"=>"2015-10-17 20:06:39.212512+00"}]}
 ```

See specs for more real world usage examples.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Maintenance

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0](http://semver.org/).
Violations of this scheme should be reported as bugs. Specifically,
if a minor or patch version is released that breaks backward
compatibility, a new version should be immediately released that
restores compatibility. Breaking changes to the public API will
only be introduced with new major versions.

As a result of this policy, you can (and should) specify a
dependency on this gem using the [Pessimistic Version Constraint](http://docs.rubygems.org/read/chapter/16#page74) with two digits of precision.

For example:

    spec.add_dependency 'letter_group', '~> 0.1'

## Contributing

1. Fork it ( https://github.com/[my-github-username]/letter_group/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
