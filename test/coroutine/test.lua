
local function test4(arg1, arg2)
    arg1 = arg1 .. '6'
    arg2 = arg2 .. 'f'
    return arg1, arg2
end

local function test_coroutine3(arg1, arg2)
    arg1 = arg1 .. '5'
    arg2 = arg2 .. 'e'
    arg1, arg2 = test4(arg1, arg2)

    arg1, arg2 = coroutine.yield(arg1, arg2)
    return arg1, arg2
end

local function test_coroutine2(arg1, arg2)
    arg1 = arg1 .. '3'
    arg2 = arg2 .. 'c'

    arg1, arg2 = coroutine.yield(arg1, arg2)

    return test_coroutine3(arg1, arg2)
end

local function test_coroutine1(arg1, arg2)
    arg1 = arg1 .. '2'
    arg2 = arg2 .. 'b'
    arg1, arg2 = test_coroutine2(arg1, arg2)
    arg1 = arg1 .. '8'
    arg2 = arg2 .. 'h'

    return arg1, arg2
end

function co_test(arg1, arg2)
    local co = coroutine.create(test_coroutine1)
    local ret
    ret, arg1, arg2 = coroutine.resume(co, arg1, arg2)
    arg1 = arg1 .. '4'
    arg2 = arg2 .. 'd'
    ret, arg1, arg2 = coroutine.resume(co, arg1, arg2)

    arg1 = arg1 .. '7'
    arg2 = arg2 .. 'g'
    ret, arg1, arg2 = coroutine.resume(co, arg1, arg2)
    arg1 = arg1 .. '9'
    arg2 = arg2 .. 'i'
    return arg1, arg2
end




-- local co = coroutine.create(test_coroutine)
--
-- print('will test coroutine')
-- local st, year = coroutine.resume(co, 1, 2)
-- print('final ------> status, year', st, year)
--
-- print('will test coroutine2')
-- st, year = coroutine.resume(co, 3, 4)
-- print('final ------> status, year2', st, year)
--
-- print('is suspended', coroutine.status(co))
--
-- print('coroutine 3', coroutine.running())
--
-- local status, a, b, c = coroutine.resume(co, 5, 6)
-- print('final ------> status', status, a, b, c)
--
-- print('is dead', coroutine.status(co))
--
-- print('coroutine 4', coroutine.running())
--

