
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
    print('coroutine3 step 1')
    local arg1, arg2 = coroutine.yield(1992)
    print('coroutine3 step 2 <<<', arg1, arg2, '>>>\n')
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
    print('hwllow')
end

local co = coroutine.create(test_coroutine)

print('will test coroutine')
print(coroutine.resume(co, 1, 2))

print('will test coroutine2')
print(coroutine.resume(co, 3, 4))

print('coroutine 3')

print(coroutine.resume(co, 5, 6))

print('coroutine 4')


