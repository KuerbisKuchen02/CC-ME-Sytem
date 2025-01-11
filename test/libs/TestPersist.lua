local c = require("libs.class")
local Test = require("libs.test")
local Persist = require("libs.Persist")
local util = require("libs.util")

local TestPersist = c.class(Test)

function TestPersist:constructor ()
    self:super("constructor", "TestPersist.lua")
end

function TestPersist:testLoad ()
    local p = Persist("test/resources/persistTestData")
    Test:assertDeepEquals(p._data, {a=21, b=12, hello="world", foo={1, 2, 3}}, "Data was not saved and loaded correctly")
end

function TestPersist:testPersistWithCustomConstructor ()
    local TestClass = c.class()
    function TestClass:constructor (a, b)
        self.a = a
        self.b = b
    end

    function TestClass.__tostring (obj)
        return string.format("D(%s,%s)", util.serialize(obj.a), util.serialize(obj.b))
    end

    function TestClass.load (...)
        return TestClass(...)
    end

    local p = Persist("test/resources/persistTestCustomConstructor")
    table.insert(p._data, TestClass(1, "hallo"))
    p._data.a = TestClass(3, true)
    table.insert(p._data, TestClass("welt", {}))
    p:save()
    local p2 = Persist("test/resources/persistTestCustomConstructor", TestClass.load)
    Test:assertDeepEquals(p2._data, {TestClass(1, "hallo"), a=TestClass(3, true), TestClass("welt", {})}, "Data was not saved and loaded correctly")
    os.remove("test/resources/persistTestCustomConstructor.lua")
end

TestPersist():run()