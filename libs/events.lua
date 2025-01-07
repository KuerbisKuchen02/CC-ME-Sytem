--- More advanced event system for computercraft

local events = {}

--- Add a new event
---
--- @param event string name of the event
--- @return boolean true if event was added, false if event already exists
local function addEvent (event)
    assert(type(event) == "string", "Event must be a string")

    if events[event] then
        return false
    end
    events[event] = {}
    return true
end

--- Remove an event
---
--- @param event string name of the event
--- @return boolean true if event was removed, otherwise false
local function removeEvent (event)
    assert(type(event) == "string", "Event must be a string")

    if not events[event] then
        return false
    end
    events[event] = nil
    return true
end

--- Clear all events and handlers
local function clearEvents ()
    events = {}
end

--- Add a new handler to an event
---
--- @param event string name of the event
--- @param func function function which will be called if event is triggered
--- @return boolean true if handler was added, false if handler already exists
local function addHandler (event, func)
    assert(type(event) == "string", "Event must be a string")
    assert(type(func) == "function", "Handler must be a function")

    local e = events[event] or {}
    for _, handler in pairs(events[event]) do
        if handler == func then
            return false
        end
    end
    table.insert(e, func)
    return true
end

--- Remove a handler from an event
---
--- @param event string name of the event
--- @param func function function which should be removed
--- @return boolean true if handler was removed, false otherwise
local function removeHandler (event, func)
    assert(type(event) == "string", "Event must be a string")
    assert(type(func) == "function", "Handler must be a function")

    if not events[event] then
        return false
    end
    for i, handler in ipairs(events[event]) do
        if handler == func then
            table.remove(events[event], i)
            return true
        end
    end
    return false
end

--- Clear all handlers from an event
---
--- @param event string name of the event
--- @return boolean true if handlers were removed, false if event doesnt exist
local function clearHandlers (event)
    assert(type(event) == "string", "Event must be a string")

    if not events[event] then
        return false
    end
    events[event] = {}
    return true
end

--- Trigger an event
---
--- @param event string name of the event
--- @param ... unknown additional parameter that will be passed to the handlers
--- @return boolean true if event was triggered, false if event doesnt exist
local function trigger (event, ...)
    assert(type(event) == "string", "Event must be a string")

    if not events[event] then
        return false
    end
    for _, func in pairs(events[event]) do
        func(...)
    end
    return true
end

--- Block and wait until an event is fired or a timeout occures 
---
--- @param timeout number|nil time in seconds
local function pullEvent (timeout)
    assert(timeout == nil or type(timeout) == "number", "Timeout must be a number or nil")

    if timeout then
        os.startTimer(timeout)
    end
    trigger(os.pullEvent())
end

--- Block and wait until an event is fired or a timeout occures.
--- Catches also termintate events
---
--- @param timeout number|nil time in seconds
local function pullEventRaw (timeout)
    assert(timeout == nil or type(timeout) == "number", "Timeout must be a number or nil")

    if timeout then
        os.startTimer(timeout)
    end
    trigger(os.pullEventRaw())
end

--- return the module
return {
    addEvent = addEvent,
    removeEvent = removeEvent,
    clearEvents = clearEvents,
    addHandler = addHandler,
    removeHandler = removeHandler,
    clearHandlers = clearHandlers,
    trigger = trigger,
    pullEvent = pullEvent,
    pullEventRaw = pullEventRaw
}
