
local mymod = require "addition"

function test_add(x,y)
    -- coroutine.yield()
    return mymod.add(x,y)
end

local function test_coroutine()
    print('coroutine step 1')
    coroutine.yield()
    print('coroutine step 2')
end

local co = coroutine.create(test_coroutine)

print('will test coroutine')
print(coroutine.resume(co, 1, 2))

