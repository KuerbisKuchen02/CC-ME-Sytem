local c = require("libs.class")
local util = require("libs.util")

--- Class for persisting data to a file
--- @class Persist
local Persist = c.class()

--- Create a new Persist object
---
--- @param filename string the filename without file extension to save the data to
--- @param loadFunc? function the function to load the data from the file
function Persist:constructor (filename, loadFunc)
    assert(type(filename) == "string", "Filename must be a string")
    assert(type(loadFunc) == "function" or loadFunc == nil, "Init function must be a function or nil")
    self.loadFunc = loadFunc
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

--- Persist the data to the file
---
--- if the object to persist has a save function, it will be called to serialize the object
--- otherwise the object will be serialized using util.serialize
--- the data will be saved to the file as a lua table at the location specified in the constructor
function Persist:save ()
    local file, err = io.open(self._filename, "w")
    if not file then error("Cannot open file: " .. err) end
    file:write("return {")
    for i, v in pairs(self._data) do
        if type(v) == "table" and v.save then
            file:write(string.format("[%q]=%s,", i, v:save()))
        else
            file:write(string.format("[%q]=%s,", i, util.serialize(v)))
        end
    end
    file:write("}")
    file:close()
end

--- Load the data from the file
---
--- the data will be loaded from the file specified in the constructor
--- if a load function was provided in the constructor, it will be used to load the data
function Persist:load ()
    local f, err = loadfile(self._filename, "t", {D = self.loadFunc})
    if not f then
        error("Cannot load data from file '" .. self._filename .. "' because: " .. err)
    end
    local reusults = {pcall(f)}
    if reusults[1] then
        self._data = reusults[2] or {}
    else
        error("Cannot load data from file '" .. self._filename .. "' because: " .. reusults[2])
    end
end

return Persist