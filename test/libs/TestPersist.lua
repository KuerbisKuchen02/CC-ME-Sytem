local c = require("libs.class")
local Test = require("libs.test")
local Persist = require("libs.Persist")

local TestPersist = c.class(Test)

function TestPersist:constructor ()
    self:super("constructor", "TestPersist.lua")
end

function TestPersist:testLoad ()
    local p = Persist("test/libs/persistTestData")
    Test:assertDeepEquals(p._data, {a=21, b=12, hello="world", foo={1, 2, 3}}, "Data was not saved and loaded correctly")
end

TestPersist():run()