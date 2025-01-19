--- The peripheral controller provides an interface to interact with external peripherals.

--- Get all peripherals that implement the generic inventory interface
---
--- @return table the peripheral names
local function getAllInventories ()
    local inventories = {}
    local peripherals = peripheral.getNames()
    for _, peripheralId in ipairs(peripherals) do
        if peripheral.hasType(peripheralId, "inventory") then
            table.insert(inventories, peripheralId)
        end
    end
    return inventories
end

--- Wrap a peripheral
---
--- @param peripheralName string the name of the peripheral
--- @return boolean success or failure
--- @return table|string the wrapped peripheral or error message
local function wrapPeripheral (peripheralName)
    local p = peripheral.wrap(peripheralName)
    if not p then
        return false, "Peripheral not found"
    end
    return true, p
end

return {
    getAllInventories = getAllInventories,
    wrapPeripheral = wrapPeripheral
}