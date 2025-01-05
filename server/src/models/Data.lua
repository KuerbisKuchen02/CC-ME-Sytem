local c = require("libs.class")
local util = require("libs.util")

--- Class representing data
--- @class Data
local Data = c.class()

--- Create a new Data object
function Data:constructor()
end

--- Convert the data into string representation
--- @return string the string representation of the data
function Data:__tostring()
    return util.serialize(self)
end

return Data