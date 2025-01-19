---@diagnostic disable: param-type-mismatch
local c = require("libs.class")
local Test = require("libs.test")
local util = require("libs.util")

local TestUtil = c.class(Test)

function TestUtil:constructor ()
   self:super("constructor", "TestUtil.lua")
end

function TestUtil:testLookup ()
    local table = {"a", "b", "c"}
    local lookup = util.lookup(table)
    self:assertTrue(lookup.a)
    self:assertTrue(lookup.b)
    self:assertTrue(lookup.c)
    self:assertNil(lookup.d)
end

function TestUtil:testConcatLists ()
    local list1 = {1, 2, 3}
    local list2 = {4, 5, 6}
    local list = util.concat_lists(list1, list2)
    self:assertDeepEquals(list, {1, 2, 3, 4, 5, 6})
end

function TestUtil:testSerialize ()
    local obj = {a = 1, b = 2, c = 3}
    local str = util.serialize(obj)
    local func = load("return " .. str)
    local _, obj2 = pcall(func)
    self:assertDeepEquals(obj2, obj)
end

function TestUtil:testSplit ()
    local str = "a b c"
    local list = util.split(str)
    self:assertDeepEquals(list, {"a", "b", "c"})
end

TestUtil():run()