---@diagnostic disable: param-type-mismatch

local Test = require("libs.Test")
local c = require("libs.class")

local TestClass = c.class(Test)

function TestClass:constructor ()
    self:super("constructor", "TestClass.lua")
end

function TestClass:init ()
    self.Class1 = c.class()
    self.Class2 = c.class(self.Class1)
    self.Class3 = c.class(self.Class2)

    function self.Class1:class1()
        return "class1"
    end

    function self.Class2:class2()
        return "class2"
    end

    function self.Class3:class3()
        return "class3"
    end
end

function TestClass:testNew ()
    function self.Class1:constructor(name)
        self.name = name
        self.value = "passed"
    end
    local newObject = c.new(self.Class1, "test")

    self:assertEquals(newObject.name, "test")
    self:assertEquals(newObject.value, "passed")
    
    self:assertThrows(function() c.new("test") end)
end

function TestClass:testInheritence ()
    local newObject = c.new(self.Class3)

    self:assertEquals(newObject:class1(), "class1")
    self:assertEquals(newObject:class2(), "class2")
    self:assertEquals(newObject:class3(), "class3")
end

function TestClass:testSuper ()
    function self.Class1:constructor(name)
        self.name = name
        self.value = "passed"
    end

    function self.Class1:foo()
        return "class 1"
    end
    function self.Class2:constructor(name)
        self:super("constructor", name)
        self.value = "overridden"
        self.fooValue = self:super("foo")
    end

    function self.Class2:foo()
        return "class 2"
    end

    function self.Class3:constructor(name)
        self:super("constructor", name)
        self.value = "overoverridden"
    end

    function self.Class3:foo()
        return "class 3"
    end

    local newObject = c.new(self.Class3, "test")

    self:assertEquals(newObject.name, "test")
    self:assertEquals(newObject.value, "overoverridden")
    self:assertEquals(newObject.fooValue, "class 1")
    self.assertThrows(function() newObject:super("bar") end)
end

function TestClass:testInstanceOf ()
    local newObject1 = c.new(self.Class1)
    local newObject2 = c.new(self.Class2)
    local newObject3 = c.new(self.Class3)

    self:assertTrue(c.instanceOf(newObject1, self.Class1))
    self:assertTrue(c.instanceOf(newObject2, self.Class1))
    self:assertTrue(c.instanceOf(newObject3, self.Class1))

    self:assertFalse(c.instanceOf(newObject1, self.Class2))
    self:assertTrue(c.instanceOf(newObject2, self.Class2))
    self:assertTrue(c.instanceOf(newObject3, self.Class2))

    self:assertFalse(c.instanceOf(newObject1, self.Class3))
    self:assertFalse(c.instanceOf(newObject2, self.Class3))
    self:assertTrue(c.instanceOf(newObject3, self.Class3))
end

TestClass():run()