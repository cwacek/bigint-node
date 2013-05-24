BigInt Node
===========

This is a Node.JS port of the pure Javascript Big Integer library created by [Leemon Baird](http://www.leemon.com).

It doesn't export all functions as of yet (mostly the crypto related ones are missing ), but exports most of those
needed to simply use Big Integers. Where possible, this wrapper does its best to ensure that unsafe functions in
the original library have been removed.

### Usage

```coffeescript
BigInt = require 'bigint-node'

large = BigInt.ParseFromString("1232223582030304828202",10)
smaller = BigInt.FromInt(124442255)

large.modEquals(smaller)

console.log large.toStr(10)
# 82641132
```

### Test

`make test` will run tests using Mocha. `make coverage` will run instrumented
tests and put coverage output in tests/coverage.html


