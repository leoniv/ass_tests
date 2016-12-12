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
- Now support ```Minitest``` only
- `AssTests::Assertions` works for external or thick application ole connectors only
- Other unknown now :(

## Features

- Provides DSL for describe 1C:Enterprise application (aka "Information base")
- Support to describe many different 1C Information bases.
- Support describe exists Information bases as ```external```. Such Information bases is persistent and can't be build or remove.
- Automatically build described Information base on demand.
- Automatically close all opened connection after all tests executed. It provides `AssOle::Runtimes`
- Provides assertions for tests 1C values in Ruby side
- Provides features for testing of 1C externals like as ExternalDataProcessor and ExternalReport
- Provides features for fill data in infobases under test.

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
# Describe empty InfoBase

require 'ass_tests/minitest'
AssTests::InfoBases.describe do
  file :empty_ib
end

module ExampleTest
  # Describe runtimes
  module Runtimes
    module Ext
      is_ole_runtime :external
      run AssTests::InfoBases[:empty_ib]
    end

    module ThickApp
      is_ole_runtime :thick
      run AssTests::InfoBases[:empty_ib]
    end
  end
end

# After all was prepared loads autorun
require 'ass_tests/minitest/autorun'
```
- ```exmple_test.rb```:
```ruby
module ExampleTest
  describe 'Spec examle' do
    like_ole_runtime Runtimes::Ext
    include AssTests::Assertions

    it 'Call runtime #metaData' do
      _assert_equal metaData, metaData
    end
  end

  class TestExample < Minitest::Test
    like_ole_runtime Runtimes::Ext
    include AssTests::Assertions

    def test_runtime_metaData
      _assert_equal metaData, metaData
    end
  end

  # Shared tests
  module SharedTests
    def test_runtime_metaData
      _assert_equal metaData, metaData
    end
  end

  class TestInExternalRuntime < Minitest::Test
    like_ole_runtime Runtimes::Ext
    include AssTests::Assertions
    include SharedTests
  end

  class TestInThickAppRuntime < Minitest::Test
    like_ole_runtime Runtimes::ThickApp
    include AssTests::Assertions
    include SharedTests
  end
end

```
- also you can write native ```Minitest::Test``` for testing
  other things like this ```ordinary_test.rb```:
```ruby
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

