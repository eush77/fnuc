if browsertest?
    `sinon = window.sinon`
    `expect = window.chai.expect`
else
    chai   = require 'chai'
    chai.should()
    expect = chai.expect
    chai.use(require 'sinon-chai')
    sinon = require 'sinon'
    F = require('../src/fnuc')
    F.installTo(global, true)

{ assert, spy, mock, stub, sandbox } = sinon

# String
# Number
# Boolean
# Symbol
# Array
# Date
# Object

date = new Date(1421584085148)

class Foo

TYPES = [
    {v:undefined, t:'undefined', d:'',        truthy:false, func:false}
    {v:null,      t:'null',      d:'',        truthy:false, func:false}
    {v:false,     t:'boolean',   d:'',        truthy:false, func:false}
    {v:true,      t:'boolean',   d:'',        truthy:true,  func:false}
    {v:'',        t:'string',    d:'[empty]', truthy:false, func:String}
    {v:'str',     t:'string',    d:'',        truthy:true,  func:String}
    {v:0,         t:'number',    d:'[0]',     truthy:false, func:Number}
    {v:42,        t:'number',    d:'',        truthy:true,  func:Number}
    {v:[],        t:'array',     d:'[empty]', truthy:true,  func:Array}
    {v:[0,1,{}],  t:'array',     d:'',        truthy:true,  func:Array}
    {v:date,      t:'date',      d:'',        truthy:true,  func:Date}
    {v:{},        t:'object',    d:'[empty]', truthy:true,  func:Object, plain:true}
    {v:{a:1,b:{}},t:'object',    d:'',        truthy:true,  func:Object, plain:true}
    {v:new Foo,   t:'object',    d:'[proto]', truthy:true,  func:Object}
]
TYPE_PROTO    = TYPES.filter (spec) -> spec.t == 'object' and not spec.plain
TYPE_NO_PROTO = TYPES.filter (spec) -> spec.t != 'object' or spec.plain
TYPE_ARR      = TYPES.filter (spec) -> spec.t == 'array'
TYPE_PLAIN    = TYPES.filter (spec) -> spec.t == 'object' and spec.plain


describe 'type', ->

    describe 'for 1 arg', ->
        TYPES.forEach (spec) ->
            it "works for #{spec.t}#{spec.d}", -> type(spec.v).should.eql(spec.t)

    describe 'for 2 args', ->
        describe 'can take a string argument', ->
            TYPES.forEach (spec) ->
                it "for type #{spec.t}#{spec.d}", -> type(spec.t, spec.v).should.be.true

describe 'isplain', ->

    describe 'tells whether something is a plain object', ->
        TYPES.forEach (spec) ->
            it "for type #{spec.t}#{spec.d}", -> isplain(spec.v).should.eql !!spec.plain

describe 'merge', ->

    describe 'alters first argument with consecutive and', ->

        it 'handles no object', -> expect(merge()).to.be.undefined
        it 'handles one object', -> merge(a:1).should.eql a:1
        it 'handles two objects', -> merge({a:1},{b:2}).should.eql a:1,b:2
        it 'handles three objects', -> merge({a:1},{b:2},{c:3}).should.eql a:1,b:2,c:3
        it 'overwrites existing keys', -> merge({a:1},{a:2}).should.eql a:2
        it 'overwrites with precedence', -> merge({a:1},{a:2},{a:3}).should.eql a:3
        it 'ignores undefined values', -> merge({a:1},{a:undefined}).should.eql a:1
        it 'leaves undefined in first be', ->
            merge({a:undefined},{b:2}).should.eql a:undefined,b:2

describe 'mixin', ->

    describe 'returns a new object with all arguments merged and', ->

        it 'handles no object', -> expect(mixin()).to.eql {}
        it 'handles one object', ->
            (r = mixin(a = a:1)).should.eql a:1
            a.should.not.equal r
        it 'handles two objects', ->
            mixin(a = {a:1},{b:2}).should.eql a:1,b:2
            a.should.eql a:1
        it 'handles three objects', ->
            mixin(a = {a:1},{b:2},{c:3}).should.eql a:1,b:2,c:3
            a.should.eql a:1
        it 'overwrites existing keys', ->
            mixin(a = {a:1},{a:2}).should.eql a:2
            a.should.eql a:1
        it 'overwrites with precedence', ->
            mixin(a = {a:1},{a:2},{a:3}).should.eql a:3
            a.should.eql a:1
        it 'ignores undefined values', ->
            mixin(a = {a:1},{a:undefined}).should.eql a:1
            a.should.eql a:1
        it 'leaves undefined in first be', ->
            mixin(a = {a:undefined},{b:2}).should.eql b:2
            a.should.eql a:undefined

describe 'shallow', ->

    describe 'does a shallow copy', ->
        TYPE_NO_PROTO.forEach (spec) ->
            it "for built in type #{spec.t}#{spec.d}", ->
                r = shallow(spec.v)
                expect(r).to.eql spec.v

    describe 'wont handle proto', ->
        TYPE_PROTO.forEach (spec) ->
            it 'throws an exception', ->
                expect(->shallow(spec.v)).to.throw 'Can\'t shallow [object Object]'

    describe 'specifically', ->

        describe 'for arrays', ->

            TYPE_ARR.forEach (spec) ->
                it "copies nested by reference for #{spec.t}#{spec.d}", ->
                    r = shallow(spec.v)
                    r.should.not.equal spec.v
                    r[i].should.equal(spec.v[i]) for a, i in r
                    r.length.should.eql spec.v.length

        describe 'for objects', ->
            TYPE_PLAIN.forEach (spec) ->
                it "copies nested by reference for #{spec.t}#{spec.d}", ->
                    r = shallow(spec.v)
                    r.should.not.equal spec.v
                    v.should.equal(spec.v[k]) for k, v of r
                    Object.keys(r).length.should.eql Object.keys(spec.v).length

describe 'clone', ->

    describe 'does a deep copy', ->
        TYPE_NO_PROTO.forEach (spec) ->
            it "for built in type #{spec.t}#{spec.d}", ->
                r = clone(spec.v)
                expect(r).to.eql spec.v

    describe 'wont handle proto', ->
        TYPE_PROTO.forEach (spec) ->
            it 'throws an exception', ->
                expect(->clone(spec.v)).to.throw 'Can\'t shallow [object Object]'

    describe 'specifically', ->

        describe 'for arrays', ->
            TYPE_ARR.forEach (spec) ->
                it "clones nested for #{spec.t}#{spec.d}", ->
                    r = clone(spec.v)
                    r.should.not.equal spec.v
                    for a, i in r
                        if type 'number', a
                            r[i].should.equal(spec.v[i])
                        else
                            r[i].should.not.equal(spec.v[i])
                    r.length.should.eql spec.v.length

        describe 'for objects', ->
            TYPE_PLAIN.forEach (spec) ->
                it "clones nested for #{spec.t}#{spec.d}", ->
                    r = clone(spec.v)
                    r.should.not.equal spec.v
                    for k, v of r
                        if type 'number', v
                            v.should.equal(spec.v[k])
                        else
                            v.should.not.equal(spec.v[k])
                    Object.keys(r).length.should.eql Object.keys(spec.v).length

describe 'arity', ->

    it 'returns the arity of (f)', ->
        arity(()->).should.eql 0
        arity((a)->).should.eql 1
        arity((a,b)->).should.eql 2

    it 'chops the arity to the given number if (f,n)', ->
        arity(arity(((a,b,c)->),n)).should.eql n for n in [0..10]

    it 'has a curried variant for (n)', ->
        arity(arity(n)((a,b,c)->)).should.eql n for n in [0..10]

    describe 'unary', ->

        it 'is arity(1)', ->
            f = unary ((a,b,c,d,e) ->)
            f.length.should.eql 1

    describe 'binary', ->

        it 'is arity(2)', ->
            f = binary (a,b,c,d,e) ->
            f.length.should.eql 2

    describe 'ternary', ->

        it 'is arity(3)', ->
            f = ternary (a,b,c,d,e) ->
            f.length.should.eql 3

describe 'lpartial', ->

    describe 'partially fills in arguments from the left', ->

        it 'executes arity(0)', ->
            r = lpartial (->42)
            r.should.eql 42

        it 'executes arity(0) with arguments', ->
            r = lpartial (->42), 1, 2, 3
            r.should.eql 42

        it 'handles arity(1)', ->
            r = lpartial ((a) -> a + 42)
            r.should.be.a.function
            r(1,2,3).should.eql 43

        it 'executes arity(1) with arguments', ->
            r = lpartial ((a) -> a + 42), 1, 2
            r.should.not.be.a.function
            r.should.eql 43

        it 'works for arity(2)', ->
            r = lpartial ((a,b) -> a / b), 42
            r.should.be.a.function
            arity(r).should.eql 1
            r(2,3,4).should.eql 21

        it 'executes arity(2) with arguments', ->
            r = lpartial ((a,b) -> a / b), 42, 2
            r.should.not.be.a.function
            r.should.eql 21

        it 'works for arity(3) with one arg', ->
            r = lpartial ((a,b,c) -> a / (b / c)), 12
            r.should.be.a.function
            arity(r).should.eql 2
            r(3,2,5).should.eql 8

        it 'works for arity(3) with two arg', ->
            r = lpartial ((a,b,c) -> a / (b / c)), 12, 3
            r.should.be.a.function
            arity(r).should.eql 1
            r(2,5).should.eql 8

        it 'executes arity(3) with arguments', ->
            r = lpartial ((a,b,c) -> a / (b / c)), 12, 3, 2, 5
            r.should.not.be.a.function
            r.should.eql 8

describe 'rpartial', ->

    describe 'partially fills in arguments from the right', ->

        it 'executes arity(0)', ->
            r = rpartial (->42)
            r.should.eql 42

        it 'executes arity(0) with arguments', ->
            r = rpartial (->42), 1, 2, 3
            r.should.eql 42

        it 'handles arity(1)', ->
            r = rpartial ((a) -> a + 42)
            r.should.be.a.function
            r(1,2,3).should.eql 43

        it 'executes arity(1) with arguments', ->
            r = rpartial ((a) -> a + 42), 1, 2
            r.should.not.be.a.function
            r.should.eql 43

        it 'works for arity(2)', ->
            r = rpartial ((a,b) -> a / b), 2
            r.should.be.a.function
            arity(r).should.eql 1
            r(42,3,4).should.eql 21

        it 'executes arity(2) with arguments', ->
            r = rpartial ((a,b) -> a / b), 42, 2
            r.should.not.be.a.function
            r.should.eql 21

        it 'works for arity(3) with one arg', ->
            r = rpartial ((a,b,c) -> a / (b / c)), 2
            r.should.be.a.function
            arity(r).should.eql 2
            r(12,3,5).should.eql 8

        it 'works for arity(3) with two arg', ->
            r = rpartial ((a,b,c) -> a / (b / c)), 3, 2
            r.should.be.a.function
            arity(r).should.eql 1
            r(12,5).should.eql 8

        it 'executes arity(3) with arguments', ->
            r = rpartial ((a,b,c) -> a / (b / c)), 12, 3, 2, 5
            r.should.not.be.a.function
            r.should.eql 8

describe 'curry', ->

    it 'does nothing for arity(f) == 0', ->
        f = ->
        g = curry f
        g.should.equal f

    it 'does nothing for arity(f) == 1', ->
        f = (n) ->
        g = curry f
        g.should.equal f

    describe '(a,b) ->', ->

        div = curry (a,b) -> a / b

        it 'turns to (b) -> (a) ->', ->
            div2 = div(2)
            div2(10).should.eql 5

        it 'maintains arity for curried func', ->
            arity(div).should.eql 2

        it 'returns a smaller arity func after partial apply', ->
            div2 = div(2)
            arity(div2).should.eql 1

        it 'can still apply (a,b) to curried (a,b) ->', ->
            div(10, 2).should.eql 5

    describe '(a,b,c) ->', ->

        divt = curry (a,b,c) -> a / (b / c)

        it 'turns to (c) -> (b) -> (a) ->', ->
            div2 = divt(2)
            div4 = div2(8)
            div4(80).should.eql 20

        it 'maintains arity for curried func', ->
            arity(divt).should.eql 3

        it 'returns a small arity func after partial apply', ->
            div2 = divt(2)
            div4 = div2(8)
            arity(div2).should.eql 2
            arity(div4).should.eql 1

        it 'can be partially applied with (b,c)', ->
            div4 = divt(8, 2)
            div4(80).should.equal 20

        it 'does correct arity for partial applied', ->
            div4 = divt(8, 2)
            arity(div4).should.eql 1

        it 'can still apply (a,b,c) to curried (a,b,c) ->', ->
            divt(80, 8, 2).should.eql 20

        it 'can apply (b,c) to partial applied curried (a,b,c) ->', ->
            div2 = divt(2)
            div2(80,8).should.eql 20

        it 'doesnt splice in more arguments for a partially applied', ->
            div2 = divt(2)
            div2(100,25,4).should.eql 8

describe 'flip', ->

    describe '(a,b) ->', ->

        f = flip (f1 = (a,b) -> a / b)

        it 'flips the arguments to (b,a) ->', ->
            f(2, 10).should.eql 5

        it 'keeps arity', ->
            arity(f).should.eql 2

        it 'is commutative', ->
            flip(f).should.equal f1

        it 'flips curried functions', ->
            f = flip curry (a,b) -> a / b
            f(2,10).should.equal 5
            f(10)(2).should.equal 5

        it 'is commutative for curried functions', ->
            f = flip (f1 = curry (a,b) -> a / b)
            flip(f).should.equal f1

        it 'flips partially applied curried functions', ->
            f = flip (curry (a,b) -> a / b)(2)
            f(8).should.eql 4

        it 'is commutative for partially applied curried functions', ->
            f = flip (f1 = (curry (a,b) -> a / b)(2))
            flip(f).should.equal f1

    describe '(a,b,c) ->', ->

        f = flip (f1 = (a,b,c) -> a / (b / c))

        it 'flips the arguments to (c,b,a) ->', ->
            f(2, 3, 12).should.eql 8

        it 'keeps arity', ->
            arity(f).should.eql 3

        it 'is commutative', ->
            flip(f).should.equal f1

        it 'flips curried functions', ->
            f = flip curry (a,b,c) -> a / (b / c)
            f(2,3,12).should.equal 8
            f(12)(3)(2).should.equal 8

        it 'is commutative for curried functions', ->
            f = flip (f1 = curry (a,b,c) -> a / (b / c))
            flip(f).should.equal f1

        it 'flips partially applied curried functions', ->
            f = flip (curry (a,b,c) -> a / (b / c))(2)
            f(3,12).should.eql 8
            f(12)(3).should.eql 8

        it 'is commutative partially applied curried functions', ->
            f = flip (f1 = (curry (a,b,c) -> a / (b / c))(2))
            flip(f).should.equal f1

describe 'compose', ->

    describe '(f2,f1)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f = compose f2, f1

        it 'is turned to f2(f1)', ->
            f(6,4).should.eql 5

        it 'maintains arity for f1', ->
            arity(f).should.eql 2

    describe '(f3,f2,f1)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f3 = (d) -> d / 3
        f = compose f3, f2, f1

        it 'is turned to f3(f2(f1))', ->
            f(7,5).should.eql 2

        it 'maintains arity for f1', ->
            arity(f).should.eql 2

describe 'sequence', ->

    describe '(f1,f2)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f = sequence f1, f2

        it 'is turned to f2(f1)', ->
            f(6,4).should.eql 5

        it 'maintains arity for f1', ->
            arity(f).should.eql 2

    describe '(f1,f2,f3)', ->

        f1 = (a,b) -> a + b
        f2 = (c) -> c / 2
        f3 = (d) -> d / 3
        f = sequence f1, f2, f3

        it 'is turned to f3(f2(f1))', ->
            f(7,5).should.eql 2

        it 'maintains arity for f1', ->
            arity(f).should.eql 2

describe 'I/ident', ->

    it 'returns the arg in', ->
        I(42).should.eql 42

    it 'is of arity 1', ->
        arity(I).should.eql 1

    it 'ignores additional args', ->
        I(42,2).should.eql 42

describe 'tap', ->

    f = spy I

    it 'is the mother of all side effect funcs', ->
        tap(42,f).should.eql 42
        f.should.have.been.calledWith 42

    it 'is curried', ->
        tap(f)(42).should.eql 42

    it 'has arity 2', ->
        tap.length.should.eql 2

foldfn = (p, c) -> p + c / p
FN_TEST = [
    {n:'head',   s:'[] -> undef',    f:head,   ar:1, as:[[]],                eq:undefined}
    {n:'head',   s:'[a] -> a',       f:head,   ar:1, as:[[1,2,3]],           eq:1}
    {n:'tail',   s:'[] -> []',       f:tail,   ar:1, as:[[]],                eq:[]}
    {n:'tail',   s:'[a] -> [a]',     f:tail,   ar:1, as:[[1,2,3]],           eq:[2,3]}
    {n:'last',   s:'[] -> undef',    f:last,   ar:1, as:[[]],                eq:undefined}
    {n:'last',   s:'[a] -> a',       f:last,   ar:1, as:[[1,2,3]],           eq:3}
    {n:'concat', s:'a, a -> [a]',    f:concat, ar:0, as:[0,1,2,3],           eq:[0,1,2,3]}
    {n:'concat', s:'[a], a -> [a]',  f:concat, ar:0, as:[[0,1],2],           eq:[0,1,2]}
    {n:'concat', s:'a, [a] -> [a]',  f:concat, ar:0, as:[0,1,[2,3]],         eq:[0,1,2,3]}
    {n:'concat', s:'[a], [a] -> [a]',f:concat, ar:0, as:[[0,1],[2,3]],       eq:[0,1,2,3]}
    {n:'each',   s:'[a], fn -> undef',f:each,  ar:2, as:[[0,1,2],((a) -> a + 1)],  eq:undefined}
    {n:'map',    s:'[a], fn -> [a]', f:map,    ar:2, as:[[0,1,2],((a) -> a + 1)],  eq:[1,2,3]}
    {n:'filter', s:'[a], fn -> [a]', f:filter, ar:2, as:[[0,1,2],((a) -> a % 2)],  eq:[1]}
    {n:'fold',   s:'[a], fn, v -> *',f:fold,   ar:3, as:[[24,28],foldfn,12], eq:16}
    {n:'fold1',  s:'[a], fn -> *',   f:fold1,  ar:2, as:[[12,24,28],foldfn], eq:16}
    {n:'foldr',  s:'[a], fn, v -> *',f:foldr,  ar:3, as:[[28,24],foldfn,12], eq:16}
    {n:'foldr1', s:'[a], fn -> *',   f:foldr1, ar:2, as:[[28,24,12],foldfn], eq:16}
    {n:'all',    s:'[a], fn -> b',   f:all,    ar:2, as:[[0,1,2],((a) -> a >= 0)], eq:true}
    {n:'any',    s:'[a], fn -> b',   f:any,    ar:2, as:[[0,1,2],((a) -> a > 1)],  eq:true}
    {n:'join',   s:'[a], s -> s',    f:join,   ar:2, as:[[0,1,2],'-'],       eq:'0-1-2'}
    {n:'reverse',s:'[a] -> [a]',     f:reverse,ar:1, as:[[0,1,2]],           eq:[2,1,0]}
    {n:'split',  s:'s, s -> s',      f:split,  ar:2, as:['a#b','#'],         eq:['a','b']}
    {n:'match',  s:'s, re -> null',  f:match,  ar:2, as:['abc','d'],         eq:null}
    {n:'match',  s:'s, s -> [s]',    f:match,  ar:2, as:['abc','b'], eq:'abc'.match('b')}
    {n:'match',  s:'s, re -> [s]',   f:match,  ar:2, as:['abc',/b/], eq:'abc'.match(/b/)}
    {n:'replace',s:'s, s, s -> s',   f:replace,ar:3, as:['aba','a','b'],     eq:'bba'}
    {n:'replace',s:'s, re, s -> s',  f:replace,ar:3, as:['aba',/a/g,'b'],    eq:'bbb'}
    {n:'search', s:'s, s -> b',      f:search, ar:2, as:['aaaca', 'c'],      eq:3}
    {n:'search', s:'s, re -> b',     f:search, ar:2, as:['aaaca', /ac/],     eq:2}
    {n:'trim',   s:'s -> s',         f:trim,   ar:1, as:['  abc '],          eq:'abc'}
    {n:'ucase',  s:'s -> s',         f:ucase,  ar:1, as:['abc'],             eq:'ABC'}
    {n:'lcase',  s:'s -> s',         f:lcase,  ar:1, as:['ABC'],             eq:'abc'}
    {n:'sort',   s:'[a], f -> [a]',  f:sort,   ar:2, as:[[2,3,1],undefined], eq:[1,2,3]}
    {n:'sort',   s:'[a], f -> [a]',  f:sort,   ar:2, as:[[2,3,1],(a,b)->b-a],eq:[3,2,1]}
    {n:'uniq',   s:'null -> null',   f:uniq,   ar:1, as:[null],              eq:null}
    {n:'uniq',   s:'[a] -> [a]',     f:uniq,   ar:1, as:[[]],                eq:[]}
    {n:'uniq',   s:'[a] -> [a]',     f:uniq,   ar:1, as:[[1,2,2,1,2,3]],     eq:[1,2,3]}
    {n:'index',  s:'[a], a -> n',    f:index,  ar:2, as:[[1,2,3,4], 3],      eq:2}
    {n:'index',  s:'[a], a -> n',    f:index,  ar:2, as:[[1,2,3,4], 5],      eq:-1}
    {n:'contains',s:'[a], a -> b',   f:contains,ar:2,as:[[1,2,3,4], 3],      eq:true}
    {n:'contains',s:'[a], a -> b',   f:contains,ar:2,as:[[1,2,3,4], 5],      eq:false}
    {n:'has',    s:'{k:v}, k -> b',  f:has,    ar:2, as:[{a:1,b:2}, 'b'],    eq:true}
    {n:'get',    s:'{k:v}, k -> v',  f:get,    ar:2, as:[{a:1,b:2}, 'b'],    eq:2}
    {n:'set',    s:'{k:v}, k, v -> v',f:set,   ar:3, as:[{a:1,b:2}, 'b', 3], eq:{a:1,b:3}}
    {n:'keys',   s:'{k:v} -> [k]',   f:keys,   ar:1, as:[{a:1,b:2}],         eq:['a','b']}
    {n:'values', s:'{k:v} -> [v]',   f:values, ar:1, as:[{a:1,b:2}],         eq:[1,2]}
    {n:'add',    s:'a, a -> a',      f:add,    ar:2, as:[12,2],              eq:14}
    {n:'add',    s:'a... -> a',      f:add,    ar:2, as:[12,2,3],            eq:17}
    {n:'sub',    s:'a, a -> a',      f:sub,    ar:2, as:[12,2],              eq:10}
    {n:'sub',    s:'a... -> a',      f:sub,    ar:2, as:[12,2,3],            eq:7}
    {n:'mul',    s:'a, a -> a',      f:mul,    ar:2, as:[12,2],              eq:24}
    {n:'mul',    s:'a... -> a',      f:mul,    ar:2, as:[12,2,3],            eq:72}
    {n:'div',    s:'a, a -> a',      f:div,    ar:2, as:[12,2],              eq:6}
    {n:'div',    s:'a... -> a',      f:div,    ar:2, as:[12,2,3],            eq:2}
    {n:'mod',    s:'a, a -> a',      f:mod,    ar:2, as:[17,6],              eq:5}
    {n:'mod',    s:'a... -> a',      f:mod,    ar:2, as:[17,6,3],            eq:2}
    {n:'min',    s:'a, a -> a',      f:min,    ar:2, as:[12,2],              eq:2}
    {n:'min',    s:'a... -> a',      f:min,    ar:2, as:[12,3,2],            eq:2}
    {n:'max',    s:'a, a -> a',      f:max,    ar:2, as:[12,2],              eq:12}
    {n:'max',    s:'a... -> a',      f:max,    ar:2, as:[3,2,12],            eq:12}
    {n:'gt',     s:'a, a -> a',      f:gt,     ar:2, as:[12,11],             eq:true}
    {n:'gt',     s:'a, a -> a',      f:gt,     ar:2, as:[12,12],             eq:false}
    {n:'gte',    s:'a, a -> a',      f:gte,    ar:2, as:[12,12],             eq:true}
    {n:'gte',    s:'a, a -> a',      f:gte,    ar:2, as:[12,13],             eq:false}
    {n:'lt',     s:'a, a -> a',      f:lt,     ar:2, as:[11,12],             eq:true}
    {n:'lt',     s:'a, a -> a',      f:lt,     ar:2, as:[12,12],             eq:false}
    {n:'lte',    s:'a, a -> a',      f:lte,    ar:2, as:[12,12],             eq:true}
    {n:'lte',    s:'a, a -> a',      f:lte,    ar:2, as:[13,12],             eq:false}
    {n:'eq',     s:'a, a -> b',      f:eq,     ar:2, as:[0,0],               eq:true}
    {n:'eq',     s:'a, a -> b',      f:eq,     ar:2, as:[1,0],               eq:false}
    {n:'eq',     s:'a, a -> b',      f:eq,     ar:2, as:[{},{}],             eq:false}
    {n:'eq',     s:'a... -> b',      f:eq,     ar:2, as:[1,1,2],             eq:false}
    {n:'eq',     s:'a... -> b',      f:eq,     ar:2, as:[false,false,false], eq:true}
    {n:'eq',     s:'a... -> b',      f:eq,     ar:2, as:[0,0,1],             eq:false}
    {n:'not',    s:'a..., a -> b',   f:not_,   ar:2, as:[false, I],            eq:true}
    {n:'not',    s:'a..., a -> b',   f:not_,   ar:2, as:[0,1,(a,b) -> b == 1], eq:false}
]

FN_TEST.forEach (spec) ->
    describe spec.n, ->
        it "has signature #{spec.s}", ->
            expect(spec.f(spec.as...)).to.eql spec.eq
        if spec.ar == spec.as.length
            if spec.ar > 1
                it "has a curried variant", ->
                    if spec.ar == 2
                        expect(spec.f(spec.as[1])(spec.as[0])).to.eql spec.eq
                    else if spec.ar == 3
                        expect(spec.f(spec.as[2])(spec.as[1])(spec.as[0])).to.eql spec.eq
            it "is of arity(#{spec.ar})", ->
                spec.f.length.should.eql spec.ar

describe 'map', ->

    as = split('abc', '')

    it 'doesnt pass multiple args to map function', ->
        map as, (v, i, as) ->
            expect(i).to.be.undefined
            expect(as).to.be.undefined
            v

describe 'fold/fold1/foldr/foldr1', ->

    fs = [fold, fold1, foldr, foldr1]
    as = [0,1,2,3]

    each fs, (f) ->
        it 'doesnt pass multiple args to fold function', ->
            f as, ((p, c, i, as) ->
                expect(i).to.be.undefined
                expect(as).to.be.undefined
                p + c), 1

describe 'and', ->

    gt10 = even = lt102 = null

    beforeEach ->
        gt10  = spy gt(10)
        even  = spy (n) -> n % 2 == 0
        lt102 = spy lt(102)

    it 'is of arity(2)', ->
        arity(and_).should.eql 2

    it 'wraps two functions f, g and invokes both with &&', ->
        f = and_(gt10, even)
        f(100, 42).should.eql true
        gt10.should.have.been.calledOnce
        gt10.should.have.been.calledWith 100, 42
        even.should.have.been.calledOnce
        even.should.have.been.calledWith 100, 42
        f(8).should.eql false

    it 'wraps moar functions f, g, h and invokes both with &&', ->
        f = and_(gt10, even, lt102)
        f(100,42).should.eql true
        gt10.should.have.been.calledOnce
        gt10.should.have.been.calledWith 100, 42
        even.should.have.been.calledOnce
        even.should.have.been.calledWith 100, 42
        lt102.should.have.been.calledOnce
        lt102.should.have.been.calledWith 100, 42
        f(102).should.eql false

    it 'is aliased', ->
        F.and.should.eql F.and_

describe 'or', ->

    gt10 = even = lt102 = null

    beforeEach ->
        gt10  = spy gt(10)
        even  = spy (n) -> n % 2 == 0
        lt102 = spy lt(102)

    it 'is of arity(2)', ->
        arity(or_).should.eql 2

    it 'wraps two functions f, g and invokes both with ||', ->
        f = or_(gt10, even)
        f(8, 42).should.eql true
        gt10.should.have.been.calledOnce
        gt10.should.have.been.calledWith 8, 42
        even.should.have.been.calledOnce
        even.should.have.been.calledWith 8, 42
        f(9).should.eql false

    it 'wraps moar functions f, g, h and invokes both with ||', ->
        f = or_(gt10, even, lt102)
        f(9,42).should.eql true
        gt10.should.have.been.calledOnce
        gt10.should.have.been.calledWith 9, 42
        even.should.have.been.calledOnce
        even.should.have.been.calledWith 9, 42
        lt102.should.have.been.calledOnce
        lt102.should.have.been.calledWith 9, 42

    it 'is aliased', ->
        F.or.should.eql F.or_

describe 'not', ->

    gt10 = null

    beforeEach ->
        gt10  = spy gt(10)

    it 'is of arity(2)', ->
        arity(not_).should.eql 2

    it 'wraps a function and nots the output', ->
        f = not_(gt10)
        f(12).should.eql false
        gt10.should.have.been.calledOnce
        gt10.should.have.been.calledWith 12

    it 'is aliased', ->
        F.not.should.eql F.not_
