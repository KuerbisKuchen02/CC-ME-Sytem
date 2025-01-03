local c = require("libs.class")

--- Multitask class for running multiple functions in parallel
--- @class Multitask
local Multitask = c.class()

--- Create a new Multitask object
function Multitask:constructor ()
    self._queue = {}
end

--- Add a function to the queue
---
--- @param func function the function to add to the queue
--- @param ... any the arguments to pass to the function
function Multitask:add (func, ...)
    assert(type(func) == "function", "func must be a function")
    
    table.insert(self._queue, function() func(table.unpack(arg)) end)
end

--- Run all functions in the queue and clear the queue
function Multitask:run ()
    while #self._queue > 0 do
        parallel.waitForAll(table.unpack(self._queue))
        self._queue = {}
    end
end

