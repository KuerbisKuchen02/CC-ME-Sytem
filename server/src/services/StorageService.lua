local c = require("libs.class")
local log = require("libs.log")
local util = require("libs.util")

local peripheralController = require("server.src.controller.peripheralController")
local InventoryRepository = require("server.src.repositories.InventoryRepository")
local ItemRepository = require("server.src.repositories.ItemRepository")

--- Class for managing storage
--- @class StorageService
local StorageService = c.class()

local function formatNBT (nbt)
    local formatted = {
        displayName = nbt.displayName,
        tags = nbt.tags,
        stackSize = nbt.maxCount,
    }
    nbt.remove("displayName")
    nbt.remove("tags")
    nbt.remove("stackSize")
    nbt.remove("name")
    nbt.remove("count")
    formatted.nbt = nbt
    return formatted
end

--- Get the details of an item
---
--- Uuses the getItemDetail() method of the inventory peripheral to get the item details.
--- If the item details are already known to the storage system, the function will return early.
--- Peripherals operations are expensive and should be run in a separate thread.
---
--- @param self StorageService the storage service object
--- @param inventory table the inventory object
--- @param slot number the slot number
--- @param itemName string the name of the item
--- @param nbtHash string the hash of the NBT data of the item
local function getItemDetail (self, inventory, slot, itemName, nbtHash)
    local item = self.itemRepository:selectOne(ItemRepository.generateId(itemName, nbtHash))
    if not item or item.displayName then return end
    log.debug("Getting item details for %s%s", itemName, (nbtHash or ""))
    local details = inventory.getItemDetail(slot)
    self.inventoryRepository:update(inventory._id, formatNBT(details))
end

--- Index all items inside the given inventory.
---
--- Uses the list() function of the inventory peripheral to get item name and count in each slot.
--- If the item is not already known to the storage system the function will queue a new task to get the item details.
--- Peripheral operations are expensive and should be run in a separate thread.
---
--- @param self StorageService the storage service object
--- @param inventory table the inventory object
local function indexInventoryContent (self, inventory)
    local items = inventory.list()
    for slot, item in pairs(items) do
        local success, message = InventoryRepository.store(item.name, item.nbt, inventory._id, slot, item.count)
        if success and message then
            self.context:spawnPeripheral(function () getItemDetail(self, inventory, slot, item.name, item.nbt) end)
        end
    end
end

--- Index all items inside all attached inventories
---
--- To speed up the process, the function will spawn a new thread for each inventory.
local function indexAllItems (self)
    local inventories = InventoryRepository:select("isAttached", true)
    for _, inventory in pairs(inventories) do
        self.context:spawnPeripheral(function () indexInventoryContent(self, inventory) end)
    end
end

--- Index all attached inventories
--- 
--- The method will query all attached inventory peripherals and wrap them.
--- If an inventory is not already stored inside the database, it will be inserted.
local function indexAllInventories (self)
    local inventories = peripheralController.getAllInventories()
    local configuredInventories = self.inventoryRepository:select()
    for _, inventoryId in ipairs(inventories) do
        if not configuredInventories[inventoryId] then
            self.inventoryRepository:insert(inventoryId)
        local success, wrappedObj = peripheralController.wrapPeripheral(inventoryId)
        if success then
            wrappedObj.isAttached = true
            self.inventoryRepository:update(inventoryId, wrappedObj)
            end
        end
    end
end

--- Create a new StorageService object
---
--- @param context Context the context
function StorageService:constructor (context)
    self.context = context
    self.inventoryRepository = InventoryRepository()
    self.itemRepository = ItemRepository()

    local schema = self.context.schema
    self.config = self.context.config
        :group("inventories", "Options handling how inventories are read")
        :define("rescan", "The time in seconds between rescan of inventories", 60, schema.positive)
        :define("ignored_names", "A list of ignored inventory peripherals", {}, schema.list(schema.peripheral), util.lookup)
        :define("ignored_types", "A list of ignored inventory peripheral types", { "turtle" }, schema.list(schema.string), util.lookup)

    indexAllInventories(self)
    indexAllItems(self)
end