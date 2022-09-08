# LocalGems

A small gem to make it easy to use local gems without churning `Gemfile.lock` during
development.


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add local_gems

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install local_gems

## Usage

```
$ local_gems --init --> Symlinks the Gemfile.lock to Gemfile.local.lock
$ local_gems --enable --> Configure bundler to use local gems
$ local_gems --disable --> Configure bundler to use remote gems
```

## Development

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/timuruski/local_gems.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
