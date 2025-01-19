--- Library for managing data in a table
--- Support for selecting, inserting, updating and deleting objects and indices for faster lookups

local c = require("libs.class")
local Persist = require("libs.persist")


--- Create an index for a table
---
--- @param tab table table to create the index for
--- @param keys table keys to create the index for
local function createIndex (tab, keys)
    assert(type(tab) == "table", "Table must be a table")
    assert(type(keys) == "table", "Keys must be a table")

    local indices = {}
    for _, key in ipairs(keys) do
        indices[key] = {}
    end

    for k, v in pairs(tab) do
        for _, key in ipairs(keys) do
            local value = v[key]
            if value then
                table.insert(indices[key], v)
            end
        end
    end
    return indices
end


--- Insert an object into the indices
---
--- @param indices table indices to insert the object into
--- @param obj table object to insert
local function insertInIndices (indices, obj)
    assert(type(indices) == "table", "Indices must be a table")
    assert(type(obj) == "table", "Object must be a table")

    for key, index in pairs(indices) do
        local value = obj[key]
        if value then
            index[value] = index[value] or {}
            table.insert(index[value], obj)
        end
    end
end


--- Remove an object from the indices
---
--- @param indices table indices to remove the object from
--- @param obj table object to remove
local function removeFromIndices (indices, obj)
    assert(type(indices) == "table", "Indices must be a table")
    assert(type(obj) == "table", "Object must be a table")

    for key, index in pairs(indices) do
        if obj[key] then
            local objects = index[obj[key]]
            for i, v in ipairs(objects) do
                if v == obj then
                    table.remove(objects, i)
                    break
                end
            end
        end
    end
end


--- Update the indices from an old object to a new object
---
--- @param indices table indices to update
--- @param oldObj table old object to update
--- @param newObj table new object to update
local function updateIndices (indices, oldObj, newObj)
    for key, index in pairs(indices) do
        local value = oldObj[key]
        if value then
            local objects = index[value]
            for i, v in ipairs(objects) do
                if v == oldObj then
                    table.remove(objects, i)
                    break
                end
            end
        end
        value = newObj[key]
        if value then
            index[value] = index[value] or {}
            table.insert(index[value], newObj)
        end
    end
end


--- Clear the indices but keep the keys
---
--- @param indices table indices to clear
local function clearIndices (indices)
    for _, index in pairs(indices) do
        indices[index] = {}
    end
end


--- Persist an object
---
---@param obj DataRepository object to persist
local function persist(obj)
    obj._meta.changes = obj._meta.changes + 1
    if obj._meta.changes > 10 then
        obj:save()
        obj._meta.changes = 0
    end
end


--- Abstract class for managing data
--- @class DataRepository 
local DataRepository = c.class(Persist)

--- Constructor for DataRepository
---
--- @param indexed_keys? table keys to index
--- @param filename? string filename to save the data to
function DataRepository:constructor (indexed_keys, filename)
    if not filename and type(indexed_keys) == "string" then
        filename = indexed_keys
        indexed_keys = nil
    end
    self:super("constructor", filename or "db")
    if type(indexed_keys) == "table" then
        self._indices = createIndex(self._data, indexed_keys)
    else 
        self._indices = {}
    end
    self._meta = {changes = 0}
end

--- Selects all objects from the data table that match the given predicate
---
--- If no key and value are given, all objects are returned
--- If only a key is given, the key is used as the id
---
--- @param key any key or id to match 
--- @param value? any value to match or nil to match by id
--- @return table objects that match the value
function DataRepository:select (key, value)
    if key == nil and value == nil then
        return self._data
    end
    if value == nil then
        return {self._data[key]}
    end
    local index = self._indices[key]
    if index then
        return index[value]
    end
    local objects = {}
    for _, v in pairs(self._data) do
        if v[key] == value then
            table.insert(objects, v)
        end
    end
    return objects
end

--- Selects all objects from the data table that match the given predicate
---
--- This function does not use the indices and is slower than the select function, 
--- so it should be used sparingly and only when necessary.
---
--- @param predicate function predicate to match
--- @return table objects that match the predicate
function DataRepository:selectPredicate (predicate)
    local objects = {}
    for _, v in pairs(self._data) do
        if predicate(v) then
            table.insert(objects, v)
        end
    end
    return objects
end

--- Selects the first object from the data table that matches the given predicate
---
--- If only a key is given, the key is used as the id
---
--- @param key any key or id to match
--- @param value? any value to match or nil to match by id
--- @return table|nil object that matches the value
function DataRepository:selectOne (key, value)
    if value == nil then
        return self._data[key]
    end
    local index = self._indices[key]
    if index then
        local v = index[value]
        if v then
            return v[1]
        else
            return nil
        end
    end
    for _, v in pairs(self._data) do
        if v[key] == value then
            return v
        end
    end
    return nil
end

--- Selects the first object from the data table that matches the given predicate
---
--- This function does not use the indices and is slower than the select function, 
--- so it should be used sparingly and only when necessary.
---
--- @param predicate function predicate to match
--- @return table|nil object that matches the predicate or nil
function DataRepository:selectOnePredicate (predicate)
    for _, v in pairs(self._data) do
        if predicate(v) then
            return v
        end
    end
    return nil
end

--- Inserts an object into the data table
---
--- @param obj table object to insert
--- @param id? any optional id to insert the object at a specific index
--- @return boolean success or failure
--- @return any|string? object or error message if failed
function DataRepository:insert (obj, id)
    assert(type(obj) == "table", "Object must be a table")

    if id then
        if self._data[id] then
            return false, "Object with id " .. id .. " already exists"
        else
            obj._id = id
            self._data[id] = obj
        end
    else
        obj._id = #self._data + 1
        table.insert(self._data, obj)
    end
    insertInIndices(self._indices, obj)
    persist(self)
    return true, obj
end

--- Updates an object in the data table
---
--- @param id any id of the object to update
--- @param newObj table object to update
--- @return boolean success or failure
--- @return string? error message if failed
function DataRepository:update (id, newObj)
    assert(type(id) ~= "nil", "Id must not be nil")
    assert(type(newObj) == "table", "Object must be a table")

    local obj = self._data[id]
    if not obj then
        return false, "Object with id " .. id .. " does not exist"
    end
    for key, value in pairs(newObj) do
        obj[key] = value
    end
    updateIndices(self._indices, obj, newObj)
    persist(self)
    return true
end

--- Deletes an object from the data table
---
--- @param predicate any id of the object to delete, predicate function to match or nil to delete all objects
--- @return boolean success or failure
--- @return string? error message if failed
function DataRepository:delete (predicate)
    if predicate == nil then
        self._data = {}
        self._indices = clearIndices(self._indices)
    elseif type(predicate) == "function" then
        for _, v in pairs(self._data) do
            if predicate(v) then
                removeFromIndices(self._indices, v)
                self._data[v._id] = nil
            end
        end
    elseif self._data[predicate] then
        removeFromIndices(self._indices, self._data[predicate])
        self._data[predicate] = nil
    else
        return false, "Object with id " .. predicate .. " does not exist"
    end

    persist(self)
    return true
end


return DataRepository
