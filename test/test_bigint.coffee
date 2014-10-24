libpath = if process.env['BIGINT_COV'] then '../lib-cov' else '../lib'
BigInt = require "#{libpath}/bigint"
should = require 'should'

describe 'BigInt', ->


 describe 'Type Conversion', ->

   describe '::FromInt',->
     it 'should handle large numbers', ->
       test = BigInt.FromInt(1234438277399454)
       test.toStr(10).should.eql "1234438277399454"

     it 'should just return the bigint if given one',->
       zero = BigInt.Zero()

       test = BigInt.FromInt(zero)
       test.should.equal zero

     it 'should warn if input is too large for javascript to handle as a number',->
       (()->
         test = BigInt.FromInt(123098210923809829018095890328039820203030)
       ).should.throw()

    describe '::FromRawBytes', ->
      it 'should accept a string', ->
        bi_bytes = BigInt.FromRawBytes("james")
        bi_bytes.equals_i(456901092723).should.be.true

      it 'should accept a byte array', ->
        bi_bytes = BigInt.FromRawBytes([106,97,109,101,115])
        bi_bytes.equals_i(456901092723).should.be.true

      it 'should throw an error if array values are not bytes',->
        (()->
          BigInt.FromRawBytes([9210,256])
        ).should.throw(/not 8bit/)

    describe '#toRawBytes',->
      it 'should return a string', ->
        bi_bytes = BigInt.FromRawBytes("james")
        retbytes = bi_bytes.toRawBytes()
        should.exist(retbytes)
        retbytes.should == "james"
        retbytes.length.should == "james"

    describe '::ParseFromString', ->
      for [name,base,test,expected] in [['hex',16,'51EADE',5368542],['base32',32,'4EUIF',4684367]]
        do (name, base,test,expected)->
          it "should parse #{name}", ()->
            BigInt.ParseFromString("#{test}",base).equals_i(expected).should.be.ok

      it 'should handle very large numbers', ->
        # This is a carefully written test case. It's testing
        # against a power of 10 intentionally, since those are the only
        # thing we can guarantee has precision.
        bi = BigInt.ParseFromString("100000000000000000000000000000000",10)
        parseInt(bi.toStr(10)).should.eql 1e+32

    describe '#toStr', ->
      tests = [['hex',16,'51EADE',5368542],
               ['base32',32,'4EUIF',4684367],
               ['base10',10,'14234',14234],
               ['binary',2,'1100011',99]]
      for [name,base,expected,testval] in tests
        do (name, base,testval,expected)->
          it "should convert to #{name}",->
            test = BigInt.FromInt(testval)
            test.toStr(base).should.equal expected

      it "should pad binary strings if requested",->
        test = BigInt.FromInt(99)

        test.toStr(2,8).should.equal '01100011'
        test.toStr(2,16).should.equal '0000000001100011'


    describe '#toInt',->
      it 'should return an integer',->
        t = BigInt.FromInt(7)
        x = t.toInt()
        x.should.be.an.instanceof Number
        x.should.eql 7

      it "should throw an error if the integer is more than #{BigInt.bpe} bits",->
        t = BigInt.FromInt(9875122)
        (()->
          x = t.toInt()
        ).should.throw()

  describe 'Math Operations', ->
    vars = {}
    beforeEach ()->
      vars.zero = BigInt.Zero()
      vars.one = BigInt.FromInt(1)

    describe '#multiplyEquals', ->
      it '20 * 20 should equal 400', ->
        i20 = BigInt.FromInt(20)
        i20.multiplyEquals(BigInt.FromInt(20))
        i20.toInt().should.equal 400

      it 'should expand the array if necessary', ->
        n1 = BigInt.ParseFromString("123809128309810928",10)
        n2 = BigInt.ParseFromString("123809128309810928",10)
        n1.toStr(10).should.eql "123809128309810928"
        n2.toStr(10).should.eql "123809128309810928"

        n1 = n1.multiplyEquals n2

        n1.toStr(10).should.eql "15328700252835225777084379108221184"

    describe '#addEquals',->

      it 'should return the updated value',->
        newval = vars.zero.addEquals(vars.one)
        newval.should.exist
        newval.should.equal vars.zero

      it 'should support positive numbers',->
        vars.zero.addEquals(vars.one).toStr(10).should.eql '1'

      it 'should expand the array if necessary',->
        large = BigInt.ParseFromString("12039809348209849280398409283048",10)

        vars.one.addEquals(large)
        vars.one.eql(BigInt.ParseFromString("12039809348209849280398409283049",10)).should.be.true

    describe '#modEquals',->
      describe 'very large modulo',->
        numbers = ["3754675054686200000", "2132410864723480000", "545263645780520000",
                   "3784049960705640000", "4765570386023120000", "1141154599711940000"]
        mod = BigInt.ParseFromString('11529215046068479',10)

        for n,i in numbers
          it "should correctly compute #{n} % #{mod.toStr(10)}",->

          expected = ["7680164713944325", "11035296246879864", "3390538615301487",
                      "2467425595178888", "4004571996838173", "11291525197229058"]

          BigInt.ParseFromString(n,10).modEquals(mod).toStr(10).should.eql expected[i]

      it 'should throw an error if mod 0 is requested',->
        (()->
          vars.one.modEquals(vars.zero)
        ).should.throw()

      it 'should ensure enough padding exists',->
        number = new BigInt()
        number.repr = [12]

        number.modEquals(vars.one)
        number.repr.should.eql [0,0]


  describe 'Slicing and Dicing', ->

    describe '#getNRightmostBits',->
      it 'should return a BigInt',->
        t = BigInt.FromInt(20)
        x = t.getNRightmostBits(5)
        x.should.be.an.instanceof BigInt

      it 'should convert 1 -> 1 when requesting 4 bits', ->
        t = BigInt.FromInt(1)
        x = t.getNRightmostBits(4)
        x.should.eql BigInt.FromInt(1)

      it 'should convert 8 -> 8 when requesting 4 bits ', ->
        t = BigInt.FromInt(8)
        x = t.getNRightmostBits(4)
        x.should.eql BigInt.FromInt(8)

      it 'should convert 7 -> 3 when requesting 2 bits', ->
        t = BigInt.FromInt(7)
        x = t.getNRightmostBits(2)
        x.should.eql BigInt.FromInt(3)

      it 'should convert 9875122 -> 2 when requesting 4 bits', ->
        t = BigInt.FromInt(9875122)
        x = t.getNRightmostBits(4)
        x.should.eql BigInt.FromInt(2)

      it 'should convert 9875122 -> 437938 when requesting 20 bits', ->
        t = BigInt.FromInt(9875122)
        x = t.getNRightmostBits(20)
        x.should.eql BigInt.FromInt(437938)

      it 'should convert 9875122 -> 9875122 when requesting 30 bits', ->
        t = BigInt.FromInt(9875122)
        x = t.getNRightmostBits(30)
        x.should.eql BigInt.FromInt(9875122)

    describe '#shiftLeft',->
      it 'should correctly expand the array for a single shift',->
        int = BigInt.FromInt(15)
        int.shiftLeft(8)
        int.equals_i(3840).should.be.true

        int = BigInt.FromInt(15)
        int.shiftLeft(24)
        int.equals_i(251658240).should.be.true

      it 'should correctly expand the array with repeated shifts',->
        int = BigInt.FromInt(1)
        should_be = BigInt.FromInt(1)
        for j in [1..96] by 1
          int.shiftLeft(1)
          should_be.addEquals(should_be)
          int.eql(should_be).should.be.true



