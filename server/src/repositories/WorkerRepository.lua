local c = require("libs.class")
local util = require("libs.util")
local DataRepository = require("server.src.repositories.DataRepository")
local Worker = require("server.src.models.Worker")

--- Class for managing workers
--- @class WorkerRepository: DataRepository
local WorkerRepository = c.class(DataRepository)

--- Create a new WorkerRepository object
function WorkerRepository:constructor ()
    self:super("constructor", {"workerType"}, "db/workers")
end

--- Select workers from the database
---
--- Supports meta keys for "workerType": "processing" (not crafting or unconfigured)
---
--- @param key string? the key to match
--- @param value string? the value to match
--- @return table workers that match the predicate
function WorkerRepository:select (key, value)
    assert(type(key) == "string" or key == nil, "Key must be a string or nil")
    assert(type(value) == "string" or value == nil, "Value must be a string or nil")

    if (key == "workerType" and value == "processing") then
        return self:selectPredicate(function (worker)
            return worker.workerType ~= "crafting" and worker.workerType ~= "unconfigured"
        end)
    end
    return self:super("select", key, value)
end

--- Select a single worker from the database
---
--- @param key string the key to match
--- @param value string the value to match
--- @return Worker? worker that matches the predicate first
function WorkerRepository:selectOne (key, value)
    assert(type(key) == "string", "Key must be a string")
    assert(type(value) == "string" or value == nil, "Value must be a string or nil")

    if (key == "workerType" and value == "processing") then
        return self:selectOnePredicate(function (worker)
            return worker.workerType ~= "crafting" and worker.workerType ~= "unconfigured"
        end)
    end
    return self:super("selectOne", key, value)
    
end

--- Insert a new worker into the database
---
--- @param id string the id of the worker
--- @param workerType? string the type of the worker
--- @param displayName? string the display name of the worker
function WorkerRepository:insert (id, workerType, displayName)
    assert(type(id) == "string", "Id must be a string")
    assert(type(workerType) == "string" or workerType == nil, "Worker type must be a string or nil")
    assert(type(displayName) == "string" or displayName == nil, "Display name must be a string or nil")

    workerType = workerType or "unconfigured"
    self:super("insert", Worker(workerType, displayName), id)
end

--- Update a worker in the database
---
--- @param id string the id of the worker
--- @param workerType? string the type of the worker
--- @param displayName? string the display name of the worker
function WorkerRepository:update (id, workerType, displayName)
    assert(type(id) == "string", "Id must be a string")
    assert(type(workerType) == "string" or workerType == nil, "Worker type must be a string or nil")
    assert(type(displayName) == "string" or displayName == nil, "Display name must be a string or nil")

    workerType = workerType or "unconfigured"
    self:super("update", Worker(workerType, displayName), id)
end

--- Get all worker types
---
--- @return table workerTypes
function WorkerRepository:getWorkerTypes ()
    local workerTypes = {}
    for workerType, _ in pairs(self._indices["workerType"]) do
        table.insert(workerTypes, workerType)
    end
    return workerTypes
end

return WorkerRepository