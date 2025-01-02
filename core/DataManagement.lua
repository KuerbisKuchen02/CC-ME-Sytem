--- Library for managing data in a table
--- Support for selecting, inserting, updating and deleting objects and indices for faster lookups

local c = require("libs.class")


--- Create an index for a table
---
--- @param table table table to create the index for
--- @param key any key to index by
local function createIndex (table, key)
    local index = {}
    for k, v in pairs(table) do
        local value = v[key]
        if value then
            index[value] = index[value] or {}
            table.insert(index[value], v)
        end
    end
    return index
end


--- Insert an object into the indices
---
--- @param indices table indices to insert the object into
--- @param obj table object to insert
local function insertInIndices (indices, obj)
    for key, index in pairs(indices) do
        local value = obj[key]
        index[value] = index[value] or {}
        table.insert(index[value], obj)
    end
end


--- Remove an object from the indices
---
--- @param indices table indices to remove the object from
--- @param obj table object to remove
local function removeFromIndices (indices, obj)
    for key, index in pairs(indices) do
        local objects = index[obj[key]]
        for i, v in ipairs(objects) do
            if v == obj then
                table.remove(objects, i)
                break
            end
        end
    end
end


--- Abstract class for managing data
--- @class DataManagement 
local DataManagement = c.class()

--- Constructor for DataManagement
---
--- Initializes the data and indices tables
function DataManagement:constructor ()
    self._data = {}
    self._indices = {}
end

--- Selects all objects from the data table that match the given predicate
---
--- @param value any value to match
--- @param key any key to match or nil to match by id
--- @return table objects that match the value
function DataManagement:select (value, key)
    if key == nil and value == nil then
        return self._data
    end
    if key == nil then
        return {self._data[value]}
    end
    local index = self._indices[key]
    if index then
        return self._index[value]
    end
    local objects = {}
    for _, v in pairs(self._data) do
        if v[key] == value then
            table.insert(objects, v)
        end
    end
    return objects
end

--- Selects the first object from the data table that matches the given predicate
---
--- @param value any value to match or id to match by id
--- @param key any key to match or nil to match by id
--- @return table|nil object that matches the value
function DataManagement:selectOne (value, key)
    if key == nil then
        return self._data[value]
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

--- Inserts an object into the data table
---
--- @param obj table object to insert
--- @param id any optional id to insert the object at a specific index
function DataManagement:insert (obj, id)
    if id then
        if self._data[id] then
            error("Object with id " .. id .. " already exists")
        else
            obj._id = id
            self._data[id] = obj
        end
    else
        obj._id = #self._data + 1
        table.insert(self._data, obj)
    end
    insertInIndices(self._indices, obj)
end

--- Updates an object in the data table
---
--- @param id any id of the object to update
--- @param obj table object to update
function DataManagement:update (id, obj)
    if not self._data[id] then
        error("Object with id " .. id .. " does not exist")
    end
    for key, value in pairs(obj) do
        self._data[id][key] = value
    end
end

--- Deletes an object from the data table
---
--- @param id any id of the object to delete
function DataManagement:delete (id)
    if not self._data[id] then
        error("Object with id " .. id .. " does not exist")
    end
    removeFromIndices(self._indices, self._data[id])
    self._data[id] = nil
end

return DataManagement
