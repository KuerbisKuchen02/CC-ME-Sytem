local c = require("libs.class")
local Test = require("libs.test")
local DataRepository = require("server.src.repositories.DataRepository")

local TestDataRepository = c.class(Test)

function  TestDataRepository:constructor ()
    self:super("constructor", "TestDataRepository.lua")
end

function TestDataRepository:init ()
    self.repository = DataRepository({"group"}, "test/resources/TestDataRepositoryData")
    self.repository._data = {
        [1] = {_id = 1, name = "test1", group = "group1"},
        [2] = {_id = 2, name = "test2", group = "group2"},
        [3] = {_id = 3, name = "test3"},
    }
    self.repository._indices = {
        group = {
            group1 = {self.repository._data[1]},
            group2 = {self.repository._data[2]}
        }
    }
end

function TestDataRepository:testSelect ()
    local result = self.repository:select()
    self:assertTrue(#result == 3)
    self:assertDeepEquals(result[1], {_id = 1, name = "test1", group = "group1"})
    self:assertDeepEquals(result[2], {_id = 2, name = "test2", group = "group2"})
    self:assertDeepEquals(result[3], {_id = 3, name = "test3"})

    result = self.repository:select(1)
    self:assertTrue(#result == 1)
    self:assertDeepEquals(result[1], {_id = 1, name = "test1", group = "group1"})

    result = self.repository:select("group", "group1")
    self:assertTrue(#result == 1)
    self:assertDeepEquals(result[1], {_id = 1, name = "test1", group = "group1"})

    result = self.repository:select("name", "test2")
    self:assertTrue(#result == 1)
    self:assertDeepEquals(result[1], {_id = 2, name = "test2", group = "group2"})
end

function TestDataRepository:testSelectPredicate ()
    local result = self.repository:selectPredicate(function(obj) return obj._id == 1 or obj._id == 2 end)
    self:assertTrue(#result == 2)
    self:assertDeepEquals(result[1], {_id = 1, name = "test1", group = "group1"})
    self:assertDeepEquals(result[2], {_id = 2, name = "test2", group = "group2"})

    result = self.repository:selectPredicate(function(obj) return obj.name == "test2" end)
    self:assertTrue(#result == 1)
    self:assertDeepEquals(result[1], {_id = 2, name = "test2", group = "group2"})
end

function TestDataRepository:testSelectOne ()
    local result = self.repository:selectOne(1)
    self:assertDeepEquals(result, {_id = 1, name = "test1", group = "group1"})

    result = self.repository:selectOne("group", "group1")
    self:assertDeepEquals(result, {_id = 1, name = "test1", group = "group1"})

    result = self.repository:selectOne("name", "test2")
    self:assertDeepEquals(result, {_id = 2, name = "test2", group = "group2"})
end

function TestDataRepository:testSelectOnePredicate ()
    local result = self.repository:selectOnePredicate(function(obj) return obj._id == 1 end)
    self:assertDeepEquals(result, {_id = 1, name = "test1", group = "group1"})

    result = self.repository:selectOnePredicate(function(obj) return obj.name == "test2" end)
    self:assertDeepEquals(result, {_id = 2, name = "test2", group = "group2"})
end


function TestDataRepository:testInsert ()
    self.repository:insert({name = "test4"})
    local result = self.repository:selectOne("name", "test4")
    self:assertDeepEquals(result, {_id = 4, name = "test4"})

    self.repository:insert({name = "test5"}, "foo")

    result = self.repository:selectOne("foo")
    self:assertDeepEquals(result, {_id = "foo", name = "test5"})

    self:assertFalse(self.repository:insert({name = "test6"}, "foo"))

end

function TestDataRepository:testUpdate ()
    self.repository:update(1, {name = "test4"})
    local result = self.repository:selectOne(1)
    self:assertDeepEquals(result, {_id = 1, name = "test4", group = "group1"})

    self:assertFalse(self.repository:update(4, {name = "test4"}))
end

function TestDataRepository:testDelete ()
    self.repository:delete(1)
    local result = self.repository:selectOne(1)
    self:assertNil(result)

    self:assertFalse(self.repository:delete(4))
end

function TestDataRepository:testPersist ()
    self.repository:save()
    local repo = DataRepository({"group"}, "test/resources/TestDataRepositoryData")
    self:assertDeepEquals(repo._data, self.repository._data)
    os.remove("test/resources/TestDataRepositoryData.lua")
end

TestDataRepository():run()