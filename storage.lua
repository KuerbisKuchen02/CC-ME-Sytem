local data = require("libs.data")
local utils = require("libs.utils")

-- pattern for matching container types
NORMAL_CONTAINER = {"minecraft:chest", "reinfchest:.-_chest$"}
BULK_CONTAINER = {"techreborn:storage_unit"}

-- Load containers table from file
local containers
if not fs.exists(".db/containers") then
    containers = {
        input = {},
        output = {},
        crafting = {},
    }
else
    containers = data.getObject("containers")
end

local reserved = utils.concat_lists(containers.input, containers.output, containers.crafting)
containers.reserved=Set(reserved)

-- List of crafting turtles connected through wireless modems
local turtles = {}
-- List of indexed items
local items = {}
-- List of all learned recipes
local recipes = {}
-- List of all attached modems
local modems = {}

-- Items that need to be crafted
local crafting_queue = {}
-- Tasks that need to be done
local task_queue = {}

local function wrapPeripheralList(list)
    for i, device in ipairs(list) do
        list[i] = peripheral.wrap(device)
    end
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
                break
            end
        end
        -- match single/ bulk containers
        for _, pattern in pairs(BULK_CONTAINER) do 
            if string.match(d_subtype, pattern) then
                table.insert(containers.bulk, peripheral.wrap(name))
                break
            end
        end
        ::continue::
    end
end

local function indexItems()

end




-- Data structures for storing items and storage ontainers
--[[ items = {
    ["minecratft:test"] = {
        total_count = 20,
        entries = {
            chest_id = 2,
            slot = 3,
            count = 31
        }
    },
    ["minecratft:test2"] = {
        total_count = 20,
        entries = {
            chest_id = 2,
            slot = 3,
            count = 31
        }
    },
}
]]

containers = {
    reserved = {
        ["peripheral_name"] = true
    },
    input = {
        [1] = {
            display_name = "BlaChest",
            peripheral_name = "minecraft:chest_0",
            device = peripheral.wrap("peripheral_name")
        }
    },
    output = {},
    crafting = {},
    mixed = {
        [1] = "chest_id"
    },
    bulk = {
        [1] = "package_id"
    }
}

containers = {
    reserved = {
        ["peripheral_name"] = true
    },
    input = {
        [1] = {
            display_name = "BlaChest",
            peripheral_name = "minecraft:chest_0",
            device = peripheral.wrap("peripheral_name")
        }
    },
    output = {},
    crafting = {},
    mixed = {
        [1] = "chest_id"
    },
    bulk = {
        [1] = "package_id"
    }
}

-- Server, Static clients, mobile clients and turtles, presenters