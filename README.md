# BERT

A BERT (Binary ERlang Term) serialization library for Ruby. It can encode Ruby objects into BERT format and decode BERT binaries into Ruby objects.

Instances of the following Ruby classes will automatically be converted to the proper simple BERT type:

- Array
- Float
- Integer
- String
- Symbol

Instances of the following Ruby classes will automatically be converted to the proper complex BERT type:

- FalseClass
- Hash
- NilClass
- Regexp
- Time
- TrueClass

To designate tuples, simply prefix an Array literal with a `t` or use the `BERT::Tuple` class:

```ruby
t[:foo, [1, 2, 3]]
BERT::Tuple[:foo, [1, 2, 3]]
```

Both of these will be converted to (in Erlang syntax):

```erlang
{foo, [1, 2, 3]}
```

## Installation

TODO: figure out the gem situation (need to fork or...?)

## Usage

```ruby
require 'bert'

bert = BERT.encode(t[:user, { name: 'TPW', nick: 'mojombo' }])
# => "\203h\002d\000\004userh\003d\000\004bertd\000\004dictl\000\000\000\002h\002d\000\004namem\000\000\000\003TPWh\002d\000\004nickm\000\000\000\amojomboj"

BERT.decode(bert)
# => t[:user, {:name=>"TPW", :nick=>"mojombo"}]
```

## Copyright

Copyright (c) 2009 Tom Preston-Werner

Copyright (c) 2023 Luna Nova

For more information, please see the [`LICENSE`](LICENSE) file.
