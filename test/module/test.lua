
local mymod = require "addition"

function test_add(x,y)
    -- coroutine.yield()
    return mymod.add(x,y)
end

local function test_a(b, c)
    print('test_a', b, c)
    return b + c
end

local function test_coroutine3()
    print('coroutine3 step 1', coroutine.running())
    local arg1, arg2 = coroutine.yield(1992)
    print('coroutine3 step 2 <<<', arg1, arg2, '>>>\n')

    -- local a = nil
    -- a = a + 1
end

local function test_coroutine2()
    print('coroutine2 step 1')
    local arg1, arg2 = coroutine.yield(1991)
    print('coroutine2 step 2 <<<', arg1, arg2, '>>>\n')
    test_coroutine3()
end

local function test_coroutine()
    local q = test_a(1, 2)
    print('q', q)
    test_coroutine2()
    print('test_coroutine end')
    return 1, 2, 3
end

local co = coroutine.create(test_coroutine)

print('will test coroutine')
local st, year = coroutine.resume(co, 1, 2)
print('final ------> status, year', st, year)

print('will test coroutine2')
st, year = coroutine.resume(co, 3, 4)
print('final ------> status, year2', st, year)

print('is suspended', coroutine.status(co))

print('coroutine 3', coroutine.running())

local status, a, b, c = coroutine.resume(co, 5, 6)
print('final ------> status', status, a, b, c)

print('is dead', coroutine.status(co))

print('coroutine 4', coroutine.running())


a = [[
   message Phone {
      optional string name        = 1;
      optional int64  phonenumber = 2;
   }
   message Person {
      optional string name     = 1;
      optional int32  age      = 2;
      optional string address  = 3;
      repeated Phone  contacts = 4;
   } ]]
local ns, oct, hex, s, pos = a:match("^([+-]?)(0?)([xX]?)([0-9a-fA-F]+)%s*()", 56)
print('ns is ', ns, 'oct is ', oct, 'hex is ', hex, 's is ', s, 'pos is ', pos)

