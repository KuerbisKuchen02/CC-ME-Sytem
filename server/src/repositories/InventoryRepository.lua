local c = require("libs.class")
local util = require("libs.util")
local DataRepository = require("server.src.repositories.DataRepository")
local Inventory = require("server.src.models.Inventory")

--- Class for managing inventories
--- @class InventoryRepository: DataRepository
local InventoryRepository = c.class(DataRepository)

--- Create a new InventoryRepository object
function InventoryRepository:constructor ()
    self:super("constructor", {"displayName", "inventoryType"}, "db/inventories")
end

--- Select inventories from the database
---
--- Supports meta keys for "inventoryType": "reserved" (input + output) and "storage" (mixed + bulk)
---
--- If no key and value are given, all objects are returned.
--- If only a key is given, the key is used as the id
---
--- @param key? string key or id to match
--- @param value? string value to match or nil to match by id
--- @return table inventories that match the predicate
function InventoryRepository:select (key, value)
    assert(type(key) == "string" or key == nil, "Key must be a string or nil")
    assert(type(value) == "string" or value == nil, "Value must be a string or nil")
    if key == "inventoryType" then
        if value == "reserved" then
            return util.concat_lists(self:super("select", key, "input"), self:super("select", key, "output"))
        elseif value == "storage" then
            return util.concat_lists(self:super("select", key, "mixed"), self:super("select", key, "bulk"))
        end
    end
    return self:super("select", key, value)
end

--- Select a single inventory from the database
---
--- @param key string key or id to match
--- @param value string value to match or nil to match by id
--- @return Inventory? inventory that matches the predicate first
function InventoryRepository:selectOne (key, value)
    assert(type(key) == "string", "Key must be a string or nil")
    assert(type(value) == "string" or value == nil, "Value must be a string or nil")
    if key == "inventoryType" then
        if value == "reserved" then
            return self:super("selectOne", key, "input") or self:super("select", key, "output")
        elseif value == "storage" then
            return self:super("selectOne", key, "mixed") or self:super("select", key, "bulk")
        end
    end
    return self:super("selectOne", key, value)
end

--- Insert a new inventory into the database
---
--- @param id string the id of the inventory
--- @param inventoryType? string the type of the inventory
--- @param displayName? string the display name of the inventory
--- @param itemName? string the item id of the inventory
--- @return boolean success or failure
--- @return any|string id of object or error message
function InventoryRepository:insert (id, inventoryType, displayName, itemName)
    assert(type(id) == "string", "Id must be a string")
    return self:super("insert", Inventory(displayName, inventoryType, itemName), id)
end

--- Update an inventory in the database
---
--- @param id string the id of the inventory
--- @param inventoryType? string the type of the inventory
--- @param displayName? string the display name of the inventory
--- @param itemName? string the item id of the inventory
--- @return boolean success or failure
--- @return string? error message
function InventoryRepository:update (id, inventoryType, displayName, itemName)
    assert(type(id) == "string", "Id must be a string")
    return self:super("update", Inventory(displayName, inventoryType, itemName), id)
end

return InventoryRepository
