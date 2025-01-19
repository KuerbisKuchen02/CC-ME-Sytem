local c = require("libs.class")
local Data = require("server.src.models.Data")

--- Class representing an inventory
--- @class Inventory: Data
local Inventory = c.class(Data)

--- Create a new Inventory object
--- @param displayName string|nil the display name of the inventory
--- @param inventoryType string|nil the type of the inventory
--- @param itemName string|nil the item id of the inventory
function Inventory:constructor (displayName, inventoryType, itemName)
    assert(inventoryType == nil
        or inventoryType == "mixed"
        or inventoryType == "bulk"
        or inventoryType == "input"
        or inventoryType == "output",
        "inventoryType must be nil, 'mixed', 'bulk', 'input' or 'output'"
    )

    self:super()
    self.displayName = displayName
    self.inventoryType = inventoryType or "mixed"
    self.itemName = itemName
    self.isAttached = false
end

function Inventory:__tostring ()
    return string.format("D(%q, %q, %q)", self.displayName, self.inventoryType, self.itemName)
end

return Inventory