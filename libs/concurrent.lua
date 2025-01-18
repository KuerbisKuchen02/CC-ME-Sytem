local execept = require("cc.expect")

local exception_mt = {
    __name = "exception",
    __tostring = function(self) return self.message end
}

local function checkResume (co, ...)
    local ok , result = coroutine.resume(co, ...)
    if ok then return result end

    if type(result) == "string" then
        --- Support CC:T's exception protocol -- see cc.internal.exception
        result = setmetatable({message = result, thread = co}, exception_mt)
    end
    error(result, 0)
end

--- Create a new future. This allows for basic cross-thread communication.
---
--- @return fun(value: any): nil resolve A function to resolve this future. Can only be called once.
--- @return fun(): any await Wait for the future to be resolved and return its value.
local function createFuture ()
    local listening, resolved, result = false, false, nil

    local function resolve (value)
        if resolved then error("Future already resolved", 2) end
        resolved, result = true, value
        if listening then os.queueEvent("future_complete") end
    end

    local function await ()
        listening = true
        while not resolved do os.pullEvent("future_complete") end
        return result
    end

    return resolve, await
end

--- Create a new coroutine runner. This allows for running multiple coroutines concurrently.
---
--- function spawn(func: function): nil Spawn a new coroutine to run the given function. <br>
--- function hasWork(): boolean Check if there are any coroutines running or waiting to run. <br>
--- function runUntilDone(): nil Run all coroutines until they are all done. <br>
--- function runForever(): nil Run all coroutines until they are all done, then wait for more to be spawned.
---
--- @param max_size? number The maximum number of coroutines to run concurrently. Default is math.huge.
--- @return Runner
local function createRunner (max_size)
    execept(1, max_size, "number", "nil")
    max_size = max_size or math.huge
    
    local addedPrope = false

    local active, activeCount = {}, 0
    local queue, queueCount = {}, 0

    --- Spawn a new coroutine to run the given function.
    ---
    --- @param func function The function to run.
    local function spawn (func)
        execept(1, func, "function")
        queueCount = queueCount + 1
        queue[queueCount] = func
        
        if not addedPrope and queueCount == 1 then
            addedPrope = true
            os.queueEvent("concurrent_probe")
        end
    end

    --- Check if there are any coroutines running or waiting to run.
    ---
    --- @return boolean true if there are coroutines running or waiting to run, otherwise false.
    local function hasWork () return queueCount > 0  or activeCount > 0 end

    --- Run all coroutines until they are all done.
    local function runUntilDone ()
        while true do
            while activeCount < max_size and queueCount > 0 do
                local task = queue.remove(1)
                queueCount = queueCount - 1

                local co = coroutine.create(task)
                local result = checkResume(co, task)
                if coroutine.status(co) ~= "dead" then
                    activeCount = activeCount + 1
                    active[activeCount] = {co = co, filter = result or false}
                end
            end

            if activeCount == 0 then
                assert(queueCount == 0)
                return
            end

            local event = {os.pullEvent()}
            local eventName = event[1]
            if eventName == "concurrent_probe" then addedPrope = false end

            for i = activeCount, 1, -1 do
                local task = active[i]
                if not task.filter or task.filter == eventName or eventName == "terminate" then
                    local filter = checkResume(task.co, table.unpack(event, 1, event.n))
                    if coroutine.status(task.co) == "dead" then
                        table.remove(active, i)
                        activeCount = activeCount - 1
                    else
                        task.filter = filter or false
                    end
                end
            end
        end
    end

    --- Run this runner forever.
    local function runForever ()
        while true do
            runUntilDone()
            os.pullEvent("concurrent_probe")
            addedPrope = true
        end
    end

    --- A coroutine runner
    --- @class Runner
    return {
        spawn = spawn,
        hasWork = hasWork,
        runUntilDone = runUntilDone,
        runForever = runForever
    }
end

return {
    createFuture = createFuture,
    createRunner = createRunner
}