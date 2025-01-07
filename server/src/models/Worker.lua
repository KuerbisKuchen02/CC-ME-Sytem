local c = require("libs.class")
local Data = require("server.src.models.Data")

--- Class representing an worker
--- @class Worker: Data
local Worker = c.class(Data)


--- Create a new Worker object
---
--- @param workerType string the type of the turtle
--- @param displayName string the display name of the turtle
function Worker:constructor (workerType, displayName)
    self:super()
    self.workerType = workerType
    self.displayName = displayName
end

return Worker