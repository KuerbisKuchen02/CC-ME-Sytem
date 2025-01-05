local c = require("libs.class")
local Data = require("server.src.models.Data")

--- Class representing an item
--- @class Item: Data
local Item = c.class(Data)

--- Create a new Item object
---
--- @param displayName string the display name of the item
--- @param nbt? table the NBT data of the item
function Item:constructor (displayName, nbt)
    self:super()
    self.displayName = displayName
    self.nbt = nbt or {}
    self.totalCount = 0
    self.entries = {}
end

--- Add an storage location to the item
---
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
function Item:store (inventoryId, slot, count) 
    assert(type(inventoryId) == "string", "Inventory id must be a string")
    assert(type(slot) == "number", "Slot must be a number")
    assert(type(count) == "number", "Count must be a number")

    self.totalCount = self.totalCount + count
    table.insert(self.entries, {
        inventory_id = inventoryId,
        slot = slot,
        count = count
    })
end

--- Remove an storage location from the item
---
--- @param inventoryId string the inventory id
--- @param slot number the slot number
--- @param count number the count of the item
function Item:retrieve (inventoryId, slot, count)
    assert(type(inventoryId) == "string", "Inventory id must be a string")
    assert(type(slot) == "number", "Slot must be a number")
    assert(type(count) == "number", "Count must be a number")

    for i, entry in ipairs(self.entries) do
        if entry.inventory_id == inventoryId and entry.slot == slot then
            if entry.count < count then
                return error("Not enough items in storage")
            end
            self.totalCount = self.totalCount - count
            entry.count = entry.count - count
            if entry.count <= 0 then
                table.remove(self.entries, i)
            end
            break
        end
    end
end

return Item