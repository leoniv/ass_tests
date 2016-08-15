# AssTests


Framework for unit testing code written on [1C:Enterprise](http://1c.ru)
embedded programming language.

It make possible to write tests for 1C:Enterprise on Ruby easy.

**Warning! Access to 1C runtime via ```WIN32OLE```. Works only in Windows or Cygwin**

## Benefits

- Write tests on Ruby and keep it under ```git``` as text  vs write tests on 1C embedded language and keep it as external 1C binary objects.
- Write tests powered by ```Minitest```, ```RSpec```, ```mocha```, ```cucumber``` and other great Ruby libraries.
- ```WIN32OLE``` automatically convert Ruby objects into IDispatch objects when it passed as argument on to other side. It make possible passes ```mocha``` ```mock``` objects in to 1C runtime side!!!

## Trouble

- Works only in Windows or Cygwin.
- Not available methods ```eval``` and ```execute``` of 1C "Global context"
- Unpossible attach to 1C debugger.
- Now support ```Minitest::Test``` only
- Other unknown now :(

## Features

- Provides DSL for describe 1C:Enterprise application (aka "Information base")
- Support to describe many different 1C Information bases.
- Support describe exists Information bases as ```external```. Such Information bases is persistent and can't be build or remove.
- Support to make ```File``` and ```Server``` type of Information bases.
- Support to remove ```File``` and ```Server``` type of Information bases.
- Automatically build described Information base on demand.
- Automatically rebuild Information base on demand.
- Class ```InfoBase``` provides methods like  ```make```, ```rm!``` and other for easy manipulate with Information base.
- Passes required instance of class ```InfoBase``` into tests for connect to Information base for testing.
- Hold pool of opened connection with 1C information bases for decrease costs on wakeup 1C application.
- Automatically close all opened connection after all tests executed.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ass_tests'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ass_tests

## Usage


### Smal example for ```Minitest```

- ```test_helper.rb```:
```ruby
require 'ass_tests/autorun'
require 'ass_tests/info_bases'

# Describe empty InfoBase
AssTests::InfoBases.describe do
  file :empty_ib
end
```
- ```small_test.rb```:
```ruby

class SmalTest < AssTests::MiniTest::Test
  # Demands described :empty_ib information base
  use :empty_ib
  # Declare to run :empty_ib in :context of :thick application
  # and we ask keep alive connection while tests executing
  # Default :keep_alive => true.
  # If set :keep_alive => false for :thick or :thin context
  # wakeup connection will be very slowly for big applications
  context :thick, :keep_alive => true
  # If we want login in information base as some user we say:
  #   login :as => 'user', :with => 'password'
  # In this example we use empty information base without any users

  # If we say :keep_alive => true and in tests we want to manipulate
  # with data, each test mast be wrapped in 1C transaction
  # for tests isolation.
  # In this example we aren't manipulate with data
  # Warning! 1C transaction not define for :thin context,
  # for :thin context require patch information base application
  def setup
    ole.BeginTransaction
  end

  # Transaction mast be rollback for tests isolation
  def teardown
    ole.RollbackTransaction
  end

  puts infobase.name    # => "empty_ib"
  puts infobase.exists? # => "true"
  puts ole.__opened__?  # => "false"
  puts ole.class # => "AssLauncher::Enterprise::Ole::ThickApplication"

  def test_hello_world
    puts ole.__opened__?  # => "true"
    a = ole.newObject 'array'
    a.add 'Hello world'
    assert_equal 'Hello world', ole.string(a.get(0))
  end

  def test_other
    assert ole.__opened__?
  end
end
```
- also you can write native ```Minitest::Test``` for testing
  other things like this ```ordinary_test.rb```:
```ruby
# Also you can write native Minitest::Test

class OrdinaryTest < Minitest::Test
  def test_fail
    assert false
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/leoniv/ass_tests.

