--- More advanced event system for computercraft

local events = {}

--- Add a new event
---
--- @param event string name of the event
--- @return boolean true if event was added, false if event already exists
local function addEvent (event)
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
    if not events[event] then
        return false
    end
    events[event] = nil
    return true
end

--- Add a new handler to an event
---
--- @param event string name of the event
--- @param func function function which will be called if event is triggered
--- @return boolean true if handler was added, false if handler already exists
local function addHandler (event, func)
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

--- Trigger an event
---
--- @param event string name of the event
--- @param ... unknown additional parameter that will be passed to the handlers
--- @return boolean true if event was triggered, false if event doesnt exist
local function trigger (event, ...)
    if not events[event] then
        return false
    end
    for _, handler in pairs(events[event]) do
        handler.func(...)
    end
    return true
end

--- Block and wait until an event is fired or a timeout occures 
---
--- @param timeout number time in seconds
local function pullEvent (timeout)
    if timeout then
        os.startTimer(timeout)
    end
    trigger(os.pullEvent())
end

--- Block and wait until an event is fired or a timeout occures.
--- Catches also termintate events
---
--- @param timeout number time in seconds
local function pullEventRaw (timeout)
    if timeout then
        os.startTimer(timeout)
    end
    trigger(os.pullEventRaw())
end

--- return the module
return {
    addEvent = addEvent,
    removeEvent = removeEvent,
    addHandler = addHandler,
    removeHandler = removeHandler,
    trigger = trigger,
    pullEvent = pullEvent,
    pullEventRaw = pullEventRaw
}
