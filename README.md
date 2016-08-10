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


### Smal exampe for ```Minitest```

- ```test_helper.rb```:
```ruby
require 'minitest/autorun'
require 'ass_tests/mini_test'
require 'ass_tests/info_bases'

# Describe empty InfoBase
AssTests::InfoBases.describe do
  file :empty_ib
end
```
- ```small_test.rb```:
```ruby
class SmalTest < AssTest::MiniTest::Test
  # Demands described :empty_ib infobase
  use :empty_ib
  # Declare to run :empty_ib in :context of :thick application
  # and we ask kepp alive connection while tests executed
  # Default :kepp_alive => true.
  # If set :kepp_alive => false for :thick or :thin conexts
  # wakeup connection well be very slouly for big applications
  context :thick, :kepp_alive => true
  # If we whant loggining in infobase as some user we say:
  #   loggining :as => 'user', :whith => 'password'
  # In this example we use empty infobase witout any users

  # If we say :kepp_alive => true and in tests we whant to manipulate
  # whith data, each test mast be wraped in 1C transaction
  # for tests isolation.
  # In this example we arn't manipulate whith data
  # Wharning! 1C transaction not define for :thin contex,
  # for :thin contex require patch infobase application
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/ass_tests.

