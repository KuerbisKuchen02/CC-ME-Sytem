local c = require("libs.class")
local Test = require("libs.Test")
local events = require("libs.events")

local TestEvents = c.class(Test)

function TestEvents:constructor ()
    self:super("constructor", "TestEvents.lua")
end

function TestEvents:init ()
    events.clearEvents()
    events.addEvent("test")
end

function TestEvents:testAddEvent () 
    self:assertTrue(events.addEvent("newEvent"), "Event was not added")
    self:assertFalse(events.addEvent("test"), "Event was added twice")
end

function TestEvents:testRemoveEvent () 
    self:assertTrue(events.removeEvent("test"), "Event was not removed")
    self:assertFalse(events.removeEvent("test"), "Event was removed twice")
end

function TestEvents:testAddHandler ()
    local handler = function () end
    self:assertTrue(events.addHandler("test", handler), "Handler was not added")
    self:assertFalse(events.addHandler("test", handler), "Handler was added twice")
end

function TestEvents:testRemoveHandler () 
    local handler = function () end
    events.addHandler("test", handler)
    self:assertTrue(events.removeHandler("test", handler), "Handler was not removed")
    self:assertFalse(events.removeHandler("test", handler), "Handler was removed twice")
end

function TestEvents:testClearHandlers ()
    local handler = function () end
    events.addHandler("test", handler)
    events.clearHandlers("test")
    self:assertFalse(events.removeHandler("test", handler), "Event was not removed")
end

function TestEvents:testTrigger ()
    local test = false
    events.addHandler("test", function () test = true end)
    events.trigger("test")
    self:assertTrue(test, "Event was not triggered")
end

TestEvents():run()

