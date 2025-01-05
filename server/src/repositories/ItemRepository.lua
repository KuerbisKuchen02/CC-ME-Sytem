local c = require("libs.class")
local DataRepository = require("server.src.repositories.DataRepository")
local Item = require("server.src.models.Item")

--- Class for managing items
--- @class ItemRepository: DataRepository
local ItemRepository = c.class(DataRepository)

--- Create a new ItemRepository object
function ItemRepository:constructor ()
    self:super("constructor", {"displayName"}, "db/items")
end

--- Insert a new item into the database
---
--- @param name string the name of the item
--- @param displayName string the display name of the item
--- @param nbt? table the NBT data of the item
function ItemRepository:insert (name, displayName, nbt)
    assert (type(name) == "string", "Name must be a string")
    assert (type(displayName) == "string", "Display name must be a string")
    assert (type(nbt) == "table" or nbt == nil, "NBT must be a table or nil")

    self.super("insert", Item(displayName, nbt), name)
end

--- Store items in a storage location
---
--- @param name string the name of the item 
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
function ItemRepository:store (name, inventoryId, slot, count)
    assert(type(name) == "string", "Name must be a string")
    assert(type(inventoryId) == "string", "Inventory id must be a string")
    assert(type(slot) == "number", "Slot must be a number")
    assert(type(count) == "number", "Count must be a number")

    local item = self:selectOne(name)
    if not item then
        return error("Item with name " .. name .. " does not exist")
    end
    item:store(inventoryId, slot, count)
end

--- Retrieve items from a storage location
---
--- @param name string the name of the item
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
function ItemRepository:retrieve (name, inventoryId, slot, count)
    assert(type(name) == "string", "Name must be a string")
    assert(type(inventoryId) == "string", "Inventory id must be a string")
    assert(type(slot) == "number", "Slot must be a number")
    assert(type(count) == "number", "Count must be a number")
    
    local item = self:selectOne(name)
    if not item then
        return error("Item with name " .. name .. " does not exist")
    end
    item:remove(inventoryId, slot, count)
end

return ItemRepository