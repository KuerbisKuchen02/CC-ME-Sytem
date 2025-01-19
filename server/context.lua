local expect = require("cc.expect")

local c = require("libs.class")
local concurrent = require("libs.concurrent")
local Config = require("libs.config")
local Mediator = require("libs.mediator")
local log = require("libs.log")

local ItemService = require("src/services/ItemService")
local InventoryService = require("src/services/InventoryService")

--- @class Context
local Context = c.class()

local sentinel = {}

function Context:constructor ()
    self.mediator = Mediator()
    self.config = Config()

    self._modules = {}
    self._mainRunner = concurrent.createRunner()
    self._peripheralRunner = concurrent.createRunner(64)
end

function Context:require (module)
    expect(1, module, "string", "table")

    if type(module) == "string" then
        module = require(module)
    end

    local instance = self.modules[module]
    if instance == sentinel then
        error("Circular dependency detected: " .. module, 2)
    elseif instance == nil then
        self.modules[module] = sentinel
        instance = module(self)
        self.modules[module] = instance or true
    end

    return instance
end

function Context:spawn (func)
    expect(1, func, "function")
    return self.mainRunner:spawn(func)
end

function Context:spawnPeripheral (func)
    expect(1, func, "function")
    return self.peripheralRunner:spawn(func)
end

function Context:run ()
    self._mainRunner:run(self._peripheralRunner.runForever)

    local ok, err = pcall(self._mainRunner.runUntilDone)
    if not ok then
        log.error("Error: %s", err)
        error(err)
    end

    log.info("Shutting down...")
end

return Context