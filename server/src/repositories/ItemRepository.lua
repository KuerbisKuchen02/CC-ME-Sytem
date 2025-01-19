local c = require("libs.class")
local expect = require("cc.expect").expect

local DataRepository = require("server.src.repositories.DataRepository")
local Item = require("server.src.models.Item")

--- Generate an id for an item
---
--- @param name string the name of the item
--- @param nbtHash? string the hash of the NBT data of the item
local function hashItem (name, nbtHash)
    if nbtHash then
        return name .. "@" .. nbtHash
    end
    return name
end

local function unhashItem (id)
    local name, nbtHash = id:match("([^@]+)@(.+)")
    return name, nbtHash
end

--- Class for managing items
--- @class ItemRepository: DataRepository
local ItemRepository = c.class(DataRepository)

--- Create a new ItemRepository object
function ItemRepository:constructor ()
    self:super("constructor", {"name", "displayName"}, "db/items")
end

--- Insert a new item into the database
---
--- @param name string the name of the item
--- @param nbtHash? string the NBT data of the item
--- @return boolean success or failure
--- @return Item|string object or error message if failed
function ItemRepository:insert (name, nbtHash)
    expect(1, name, "string")
    expect(2, nbtHash, "string", "nil")

    return self:super("insert", Item(name, nbtHash), hashItem(name, nbtHash))
end

--- Store items in a storage location
---
--- If the item does not exist in the database, it will be inserted first.
---
--- @param itemId string the id of the item
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
--- @return boolean success or failure
--- @return string? message if failed or added item to database
function ItemRepository:storeById(itemId, inventoryId, slot, count)
    expect(1, itemId, "string")
    expect(2, inventoryId, "string")
    expect(3, slot, "number")
    expect(4, count, "number")

    local item = self:selectOne(itemId)
    if item then
        item:store(inventoryId, slot, count)
        return true
    end
    local success, item = self:insert(unhashItem(itemId))
    if success then
        ---@diagnostic disable-next-line: param-type-mismatch
        item:store(inventoryId, slot, count)
        return true, "Added item to database"
    end
    ---@diagnostic disable-next-line: return-type-mismatch
    return false, item
end

--- Store items in a storage location
---
--- If the item does not exist in the database, it will be inserted first.
---
--- @param name string the name of the item
--- @param nbtHash? string the nbtHash of the item
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
--- @return boolean success or failure
--- @return string? message if failed or added item to database
function ItemRepository:store (name, nbtHash, inventoryId, slot, count)
    expect(1, name, "string")
    expect(2, nbtHash, "string", "nil")
    return self:storeById(hashItem(name, nbtHash), inventoryId, slot, count)
end

--- Retrieve items from a storage location
---
--- @param itemId string the id of the item
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
--- @return boolean success or failure
--- @return string? error message if failed
function ItemRepository:retrieveById (itemId, inventoryId, slot, count)
    expect(1, itemId, "string")
    expect(2, inventoryId, "string")
    expect(3, slot, "number")
    expect(4, count, "number")

    local item = self:selectOne(itemId)
    if item then
        return item:retrieve(inventoryId, slot, count)
    end
    return false, "Item with id " .. itemId .. " does not exist"
end

--- Retrieve items from a storage location
---
--- @param name string the name of the item
--- @param nbtHash? string the NBT data of the item
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
--- @return boolean success or failure
--- @return string? error message if failed
function ItemRepository:retrieve (name, nbtHash, inventoryId, slot, count)
    expect(1, name, "string")
    expect(2, nbtHash, "string", "nil")
    return self:retrieveById(hashItem(name, nbtHash), inventoryId, slot, count)
end

return ItemRepository