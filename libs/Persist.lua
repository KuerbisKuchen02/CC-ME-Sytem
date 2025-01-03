local c = require("libs.class")
local util = require("libs.util")

--- Class for persisting data to a file
--- @class Persist
local Persist = c.class()

--- Create a new Persist object
---
--- @param filename string the filename without file extension to save the data to
function Persist:constructor (filename)
    assert(type(filename) == "string", "Filename must be a string")

    self._filename = filename .. ".lua"
    if io.open(self._filename, "r") then
        self:load()
    else
        self._data = {}
    end
end

--- Destructor for Persist
function Persist:destructor ()
    self:save()
end

--- Load the data from the file
function Persist:load ()
    local reusults = {pcall(dofile, self._filename)}
    if reusults[1] then
        self._data = reusults[2] or {}
    else
        error("Cannot load data from file '" .. self._filename .. "' because: " .. reusults[2])
    end
end

--- Persist the data to the file
function Persist:save ()
    local file = io.open(self._filename, "w")
    if not file then error("Cannot open file") end
    file:write("return ", util.serialize(self._data))
    file:close()
end

return Persist