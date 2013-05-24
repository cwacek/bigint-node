BigInt = require '../lib/bigint'
should = require 'should'

describe 'BigInt', ->

   describe 'FromInt',->
     it 'should handle very large numbers', ->
       test = BigInt.FromInt(1234438277399454)
       test.toStr(10).should.eql "1234438277399454"

  describe 'raw bytes functions', ->
    bytes = "james"
    bi_bytes = BigInt.FromRawBytes(bytes)

    it 'FromRawBytes should read a string of bytes', ->
      bi_bytes.equals_i(456901092723).should.be.ok

    it '#toRawBytes should return a string of raw bytes', ->
      retbytes = bi_bytes.toRawBytes()
      should.exist(retbytes)
      retbytes.should == bytes
      retbytes.length.should == bytes

    it 'FromRawBytes should read a byte array', ->
      bi_bytes = BigInt.FromRawBytes([106,97,109,101,115])
      bi_bytes.equals_i(456901092723).should.be.true

  describe 'parseFromString', ->
    it "should parse correctly from base32", ->
      BigInt.parseFromString("4EUIF",32,1).equals_i(4684367).should.be.ok

    it 'should handle very large numbers', ->
      # This is a very carefully written test case. It's testing
      # against a power of 10 intentionally, since those are the only
      # thing we can guarantee has precision.
      bi = BigInt.parseFromString("100000000000000000000000000000000",10,1)
      parseInt(bi.toStr(10)).should.eql 1e+32

  describe '#toStr', ->
    it "should convert to base32", ->
      test = BigInt.FromInt(100000)
      test.toStr(32).should.equal "31L0"

  describe '#multiplyEquals', ->
    it '20 * 20 should equal 400', ->
      i20 = BigInt.FromInt(20)
      i20.multiplyEquals(BigInt.FromInt(20))
      i20.asInt().should.equal 400

    it 'should expand the array if necessary', ->
      n1 = BigInt.parseFromString("123809128309810928",10,0)
      n2 = BigInt.parseFromString("123809128309810928",10,0)
      n1.toStr(10).should.eql "123809128309810928"
      n2.toStr(10).should.eql "123809128309810928"

      n1 = n1.multiplyEquals n2

      n1.toStr(10).should.eql "15328700252835225777084379108221184"

  describe '#addEquals',->
    it 'should expand the array if necessary',->
      small = BigInt.FromInt(1)
      large = BigInt.parseFromString("12039809348209849280398409283048",10,0)

      small.addEquals(large)
      small.eql(BigInt.parseFromString("12039809348209849280398409283049",10,0)).should.be.true

  describe '#modEquals',->
    describe 'very large modulo',->
      numbers = ["3754675054686200000", "2132410864723480000", "545263645780520000",
                 "3784049960705640000", "4765570386023120000", "1141154599711940000"]
      mod = BigInt.parseFromString('11529215046068479',10,0)

      for n,i in numbers
        it "should correctly compute #{n} % #{mod.toStr(10)}",->

        expected = ["7680164713944325", "11035296246879864", "3390538615301487",
                    "2467425595178888", "4004571996838173", "11291525197229058"]

        BigInt.parseFromString(n,10,0).modEquals(mod).toStr(10).should.eql expected[i]


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

    it 'should correctly expand the array with repeated shfits',->
      int = BigInt.FromInt(1)
      should_be = BigInt.FromInt(1)
      debugger
      for j in [1..96] by 1
        int.shiftLeft(1)
        should_be.addEquals(should_be)
        int.eql(should_be).should.be.true

  describe 'asInt',->
    it 'should return an integer',->
      t = BigInt.FromInt(7)
      x = t.asInt()
      x.should.be.a 'number'
      x.should.eql 7

    it "should throw an error if the integer is more than #{BigInt.bpe} bits",->
      t = BigInt.FromInt(9875122)
      (()->
        x = t.asInt()
      ).should.throw


