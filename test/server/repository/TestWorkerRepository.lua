local c = require("libs.class")
local Test = require("libs.Test")
local WorkerRepository = require("server.src.repositories.WorkerRepository")

local TestWorkerRepository = c.class(Test)

function TestWorkerRepository:constructor ()
    self:super("constructor", "TestWorkerRepository.lua")
end

function TestWorkerRepository:init()
    self.repo = WorkerRepository:new()
    self.repo:insert("minecraft:worker1", "crafting")
    self.repo:insert("minecraft:worker2", "furnance", "Super Smelter")
    self.repo:insert("minecraft:worker3", "blast furnace", "Ore")
    self.repo:insert("minecraft:worker4", "pulveriser")
end

function TestWorkerRepository:testSelect ()
    local workers = self.repo:select("workerType", "processing")
    self:assertTrue(#workers == 3, "Expected 3 workers, got " .. #workers)

    -- all other cases are tested in TestDataRepository.lua
end

function TestWorkerRepository:testSelectOne ()
    local worker = self.repo:selectOne("workerType", "processing")
    self:assertTrue(worker._id == "minecraft:worker2" or worker._id == "minecraft:worker3" or worker._id == "minecraft:worker4",
    "Expected worker2 or worker3 or worker4, got " .. worker._id)

    -- all other cases are tested in TestDataRepository.lua
end

function TestWorkerRepository:testGetWorkerTypes ()
    local workerTypes = self.repo:getWorkerTypes()
    self:assertTrue(#workerTypes == 4, "Expected 4 worker types, got " .. #workerTypes)
end
-- insert and update are tested in TestDataRepository.lua

TestWorkerRepository():run()
