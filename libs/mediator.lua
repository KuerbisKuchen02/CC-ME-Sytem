--- Basic Mediator/ Observer pattern implementation

local c = require("libs.class")
local expect = require("cc.expect")

---- Mediator class
---- @class Mediator
local Mediator = c.class()

function Mediator:constructor ()
    self.listeners = {}
end

--- Check if an event has subscribers
--- @param event string event name
--- @return boolean true if event has subscribers, otherwise false
function Mediator:hasSubscribers (event)
    expect(1, event, "string")
    return self.listeners[event] ~= nil
end

--- Subscribe to an event with a callback function
--- @param event string event name
--- @param func function callback function
function Mediator:subscribe (event, func)
    expect(1, event, "string")
    expect(2, func, "function")
    self.listeners[event] = self.listeners[event] or {}
    table.insert(self.listeners[event], func)
end

--- Unsubscribe from an event
--- @param event string event name
--- @param func function callback function
function Mediator:unsubscribe (event, func)
    expect(1, event, "string")
    expect(2, func, "function")
    if not self.listeners[event] then
        return
    end
    for i, l in ipairs(self.listeners[event]) do
        if l == func then
            table.remove(self.listeners[event], i)
            return
        end
    end
end

--- Publish an event
--- @param event string event name
--- @param ... any arguments
function Mediator:publish (event, ...)
    expect(1, event, "string")
    if not self.listeners[event] then
        return
    end
    for _, l in ipairs(self.listeners[event]) do
        l(...)
    end
end

return Mediator
