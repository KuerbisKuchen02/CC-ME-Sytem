local c = require("libs.class")
local Test = require("libs.Test")
local Inventory = require("server.src.models.Inventory")
local InventoryRepository = require("server.src.repositories.InventoryRepository")

local TestInventoryRepository = c.class(Test)

function TestInventoryRepository:constructor ()
    self:super("constructor", "TestInventoryRepository.lua")
end

function TestInventoryRepository:init()
    self.repo = InventoryRepository:new()
    self.repo:insert("minecraft:chest1", "input", "Base input")
    self.repo:insert("minecraft:chest2", "output", "Base output")
    self.repo:insert("minecraft:chest3", "mixed", "Storage")
    self.repo:insert("minecraft:chest4", "bulk", "Cobblestone", "minecraft:cobblestone")
end

function TestInventoryRepository:testSelect ()
    local result = self.repo:select("inventoryType", "reserved")
    self:assertTrue(#result == 2, "Expected 2 inventories, got " .. #result)

    result = self.repo:select("inventoryType", "storage")
    self:assertTrue(#result == 2, "Expected 2 inventories, got " .. #result)

    -- all other cases are tested in TestDataRepository.lua
end

function TestInventoryRepository:testSelectOne ()
    local result = self.repo:selectOne("inventoryType", "reserved")
    self:assertTrue(result._id == "minecraft:chest1" or result._id == "minecraft:chest2",
        "Expected minecraft:chest1 or minecraft:chest2, got " .. result._id)

    result = self.repo:selectOne("inventoryType", "storage")
    self:assertTrue(result._id == "minecraft:chest3" or result._id == "minecraft:chest4",
        "Expected minecraft:chest3 or minecraft:chest4, got " .. result._id)

    -- all other cases are tested in TestDataRepository.lua
end

-- insert and update are tested in TestDataRepository.lua

TestInventoryRepository():run()