local c = require("libs.class")
local Test = require("libs.test")
local ItemRepository = require("server.src.repositories.ItemRepository")

local TestItemRepository = c.class(Test)

function TestItemRepository:constructor ()
    self:super("constructor", "TestItemRepository.lua")
end

function TestItemRepository:init ()
    self.repo = ItemRepository:new()
    self.repo:insert("minecraft:stone")
    self.repo:insert("minecraft:iron_ingot")
end

function TestItemRepository:testStore ()
    local result = self.repo:store("minecraft:stone", nil, "minecraft:chest1", 1, 64)
    self:assertTrue(result, "Failed to store item")

    result = self.repo:store("minecraft:stone", "3ef410b68bf0a0241fbed0580f4f5473", "minecraft:chest1", 2, 2)
    self:assertTrue(result, "Failed to store item")

    local items = self.repo:select("name", "minecraft:stone")
    self:assertTrue(#items == 2, "Expected 2 item, got " .. #items)

    result = self.repo:store("minecraft:stone", nil, "minecraft:chest1", 3, 37)
    self:assertTrue(result, "Failed to store item")

    local item = self.repo:selectOne("minecraft:stone")
    self:assertTrue(item.totalCount == 101, "Expected 101 items, got " .. item.totalCount)
end

function TestItemRepository:testRetrieve ()
    self.repo:store("minecraft:stone", nil, "minecraft:chest1", 1, 64)
    self.repo:store("minecraft:stone", nil, "minecraft:chest1", 2, 2)
    self.repo:store("minecraft:stone", nil, "minecraft:chest1", 3, 37)
    local item = self.repo:selectOne("minecraft:stone")

    local result = self.repo:retrieveById(item._id, "minecraft:chest1", 1, 64)
    self:assertTrue(result, "Failed to retrieve item")

    result = self.repo:retrieveById(item._id, "minecraft:chest1", 2, 64)
    self:assertFalse(result, "Expected failure")

    result = self.repo:retrieveById(item._id, "minecraft:chest1", 3, 37)
    self:assertTrue(result, "Failed to retrieve item")

    item = self.repo:selectOne("minecraft:stone")
    self:assertTrue(item.totalCount == 2, "Expected 2 items, got " .. item.totalCount)
end

TestItemRepository():run()