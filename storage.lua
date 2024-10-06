local data = require("libs.data")
local utils = require("libs.utils")
local log = require("libs.log")

-- pattern for matching container types
NORMAL_CONTAINER = {"minecraft:chest", "reinfchest:.-_chest$"}
BULK_CONTAINER = {"techreborn:storage_unit"}

-- Load containers table from file
local containers = data.getObject("containers")

-- List of crafting turtles connected through wireless modems
local turtles = {}
-- List of indexed items
local items = {
    meta = {
        item_count = 0,
        uique_item_count = 0,
    }
}
-- List of all learned recipes
local recipes = {}

-- Items that need to be crafted
local crafting_queue = {}
-- Tasks that need to be done
local task_queue = {}

local function wrapPeripheralList(list)
    for i, device in ipairs(list) do
        list[i] = peripheral.wrap(device)
    end
    log.info("Wrapped all connected peripherals")
end

--- Populate containers list with all attached peripherals that match the container patterns
local function getAllStoarageContainers()
    containers.mixed = {}
    containers.bulk = {}
    local devices = peripheral.getNames

    for _, name in pairs(devices) do
        if containers.reserved[name] then goto continue end
        local d_subtype, d_type = peripheral.getType(name)
        if d_type ~= "inventory" then goto continue end

        -- match mixed containers
        for _, pattern in pairs(NORMAL_CONTAINER) do 
            if string.match(d_subtype, pattern) then
                table.insert(containers.mixed, peripheral.wrap(name))
                containers.meta.count_mixed = containers.meta.count_mixed + 1
                break
            end
        end
        -- match single/ bulk containers
        for _, pattern in pairs(BULK_CONTAINER) do 
            if string.match(d_subtype, pattern) then
                table.insert(containers.bulk, peripheral.wrap(name))
                containers.meta.count_bulk = containers.meta.count_bulk + 1
                break
            end
        end
        ::continue::
    end
end

--- Index all items from all containers in the given list
--- Items will be stored in the 'items' table 
---@param list table List with inventory peripherals 
local function indexItemsFromTable(list)
    for container_id, container in pairs(list) do
        for slot, item in pairs(container.list()) do
            local item_details = container.getItemDetail(slot)
            local saved_item = items[item_details.displayName]
            if not saved_item then
                items[item_details.displayName] = {}
                saved_item = items[item_details.displayName]
                saved_item.total_count = 0
                saved_item.entries = {}
                items.meta.uique_item_count = (items.meta.uique_item_count or 0) + 1
            end
            saved_item.total_count = saved_item + item_details.count
            table.insert(saved_item.entries, {
                chest_id = container_id,
                slot = slot,
                item_id = item,
                count = item_details.count
            })
            items.meta.item_count = (items.meta.item_count or 0) + item_details.count
        end
    end
end

--- Index all items from all connected storage containers
--- (bulk and mixed)
local function indexItems()
    log.info("Start indexing items...")
    indexItemsFromTable(containers.bulk)
    indexItemsFromTable(containers.mixed)
    log.info("Indexing successfull. Found %d items in $d chests"):
        format(items.meta.item_count, containers.meta.count_bulk + containers.meta.count_mixed)
end

-- Data structures for storing items and storage containers
--[[ items = {
    ["minecratft:test"] = {
        total_count = 20,
        entries = {
            [1] = {
                chest_id = 2,
                slot = 3,
                count = 31
            }
        }
    },
    ["minecratft:test2"] = {
        total_count = 20,
        entries = {
            [1] = {
                chest_id = 2,
                slot = 3,
                count = 31
            }
        }
    },
}

containers = {
    reserved = {
        ["minecraft:chest_0"] = peripheral.wrap("peripheral_name")
    },
    input = {
        ["BlaChest"] = "minecraft:chest_0"
    },
    output = {
        ["BlaChest"] = "minecraft:chest_0"
    },
    crafting = {
        "peripheral_name",
    },
    mixed = {
        ["chest_id"] = peripheral.wrap("chest_id")
    },
    bulk = {
        ["package_id"] = peripheral.wrap("package_id")
    }
}
]]

-- Server, Static clients, mobile clients and turtles, presenters


--[[

Player adds new Client with input and output chest

Player needs to map network id to an unique name 


]]

return {}

