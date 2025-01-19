local c = require("libs.class")
local Data = require("server.src.models.Data")

--- Class representing an item
--- @class Item: Data
local Item = c.class(Data)

--- Create a new Item object
---
--- @param name string the name of the item
--- @param nbtHash? string the hash of the NBT data of the item
--- @param displayName? string the display name of the item
--- @param stackSize? number the stack size of the item
--- @param tags? table the tags of the item
--- @param nbt? table the NBT data of the item
function Item:constructor (name, nbtHash, displayName, stackSize, tags, nbt)
    self:super()

    self.name = name
    self.nbtHash = nbtHash

    self.displayName = displayName
    self.tags = tags
    self.stackSize = stackSize

    self.nbt = nbt

    self.totalCount = 0
    self.storageLocations = {}
end

--- Store items in a storage location
---
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
function Item:store (inventoryId, slot, count)
    assert(type(inventoryId) == "string")
    assert(type(slot) == "number")
    assert(type(count) == "number")

    table.insert(self.storageLocations, {inventoryId, slot, count})
    self.totalCount = self.totalCount + count
end

--- Retrieve items from a storage location
---
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
--- @return boolean success or failure
--- @return string? error message if failed
function Item:retrieve (inventoryId, slot, count)
    assert(type(inventoryId) == "string")
    assert(type(slot) == "number")
    assert(type(count) == "number")

    for i, v in ipairs(self.storageLocations) do
        if v[1] == inventoryId and v[2] == slot then
            if v[3] < count then
                return false, "Not enough items in storage"
            end
            v[3] = v[3] - count
            if v[3] == 0 then
                table.remove(self.storageLocations, i)
            end
            self.totalCount = self.totalCount - count
            return true
        end
    end
    return false, "Item not found in storage"
end


return Item