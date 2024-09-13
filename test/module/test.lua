
local mymod = require "addition"

function test_add(x,y)
    -- coroutine.yield()
    return mymod.add(x,y)
end

