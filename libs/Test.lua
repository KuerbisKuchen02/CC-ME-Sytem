--- Simple testing framework for Lua. 
--- see the Test class for more information.

local c = require("libs.class")
local serialize = require("libs.util").serialize
local format = string.format


--- Deeply compare two values.
---
--- @param actual any the actual value
--- @param expected any the expected value
--- @return boolean true if the values are equal, false otherwise
local function deepEquals (actual, expected)
    if type(expected) ~= type(actual) then
        return false
    end

    if type(expected) ~= "table" then
        return expected == actual
    end
 
    for k, v in pairs(expected) do
        if not deepEquals(v, actual[k]) then
            return false
        end
    end

    for k, v in pairs(actual) do
        if not deepEquals(v, expected[k]) then
            return false
        end
    end

    return true
end

--- Test class for automatic unit testing.
---
--- Tests are defined as methods that start with "test" in the name. <br>
--- A init function can be defined to run before each test. <br>
--- Instead of returning the class at the end of the file, the TestClass():run() function should be called.
---
--- The test object has several assertion functions that can be used to test values. <br>
--- The test object also has a "name" field that can be used to identify the test. <br>
--- The test object keeps track of the number of tests that passed and failed.
--- @class Test
local Test = c.class()


--- Create a new Test object.
---
--- @param name string the name of the test
function Test:constructor (name)
    self.name = name
    self.passed = 0
    self.failed = 0
end

--- Run the tests in the test object.
function Test:run ()
    print(format("Running tests for %s", self.name))
    for name, test in pairs(getmetatable(self)) do
        if type(test) == "function" and name:sub(1, 4) == "test" then
            if (self["init"]) then
                local status, message = pcall(self["init"], self)
                if not status then
                    print(format("FAILED: %s - Reason: %s", "init", message))
                    return
                end
            end
            local status, message = pcall(test, self)
            if status then
                self.passed = self.passed + 1
                -- print(format("PASSED: %s", name))
            else
                self.failed = self.failed + 1
                print(format("FAILED: %s - Reason: %s", name, message))
            end
        end
    end

    print(format("Passed: %d, Failed: %d\n", self.passed, self.failed))
end

--- Assert that a test is true.
---
--- @param test any the test to assert
--- @param failureMessage? string the message to display if the test fails
function Test:assertTrue (test, failureMessage)
    local message = failureMessage or format("Expected true, got %s", serialize(test))
    if not test then
        error(message, 2)
    end
end

--- Assert that a test is false.
---
--- @param test any the test to assert
--- @param failureMessage? string the message to display if the test fails
function Test:assertFalse (test, failureMessage)
    local message = failureMessage or format("Expected false, got %s", serialize(test))
    if test ~= false then
        error(message, 2)
    end
end

--- Assert that two values are equal.
---
--- @param actual any the actual value
--- @param expected any the expected value
--- @param failureMessage? string the message to display if the test fails
function Test:assertEquals (actual, expected, failureMessage)
    local message = failureMessage or format("Expected %s, got %s", serialize(expected), serialize(actual))
    if expected ~= actual then
        error(message, 2)
    end
end

--- Assert that two values are not equal.
---
--- @param actual any the actual value
--- @param expected any the expected value
--- @param failureMessage? string the message to display if the test fails
function Test:assertNotEquals (actual, expected, failureMessage)
    local message = failureMessage or format("Expected %s to not equal %s", serialize(expected), serialize(actual))
    if expected == actual then
        error(message, 2)
    end
end

--- Assert that a test is nil.
---
--- @param test any the test to assert
--- @param failureMessage? string the message to display if the test fails
function Test:assertNil (test, failureMessage)
    local message = failureMessage or format("Expected nil, got %s", serialize(test))
    if test ~= nil then
        error(message, 2)
    end
end

--- Assert that a test is not nil.
---
--- @param test any the test to assert
--- @param failureMessage? string the message to display if the test fails
function Test:assertNotNil (test, failureMessage)
    local message = failureMessage or format("Expected not nil, got nil")
    if test == nil then
        error(message, 2)
    end
end

--- Assert that a function throws an error.
---
--- @param func function the function to call
--- @param failureMessage? string the message to display if the test fails
function Test:assertThrows (func, throwPatter, failureMessage)
    local status, message = pcall(func)
    local test = not status
    if throwPatter then
        status = test and message:find(throwPatter)
    end
    local message = failureMessage or format("Expected function to throw an error, got %s", serialize(message))
    if not test then
        error(message, 2)
    end
end

--- Assert that a test is within a delta of another value.
---
--- @param actual number the actual value
--- @param expected number the expected value
--- @param delta number the delta to compare the values with
--- @param failureMessage? string the message to display if the test fails
function Test:asssertDelta (actual, expected, delta, failureMessage)
    local message = failureMessage or format("Expected %s to be within %s of %s", serialize(actual), serialize(delta), serialize(expected))
    if math.abs(expected - actual) > delta then
        error(message, 2)
    end
end

--- Assert that two tables are deeply equal.
---
--- @param actual table the actual table
--- @param expected table the expected table
--- @param failureMessage? string the message to display if the test fails
function Test:assertDeepEquals (actual, expected, failureMessage)
    local message = failureMessage or format("Expected %s, got %s", serialize(expected), serialize(actual))
    if not deepEquals(actual, expected) then
        error(message, 2)
    end
end

return Test