--- Auxilary functions for other modules

--- Convert a list to a Set. Sets allow you to easily check,
--- if a value is present in a list
---
--- @param list table List which should be converted to a set
--- @return table Set set with the provided items
function Set(list)
    assert(type(list) == "table", "List must be a table")

    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end


--- Returns a new list containing all entries from both lists
---
--- @param ... table lists 
--- @return table list new list with all entries
local function concat_lists(...)
    local list = {}
    for _,l in ipairs({...}) do
        for i = 1, #l do
            table.insert(list, l[i])
        end
    end
    return list
end


--- Serialize an object
---
--- @param obj number|string|table object to serialize
--- @return string serialized object
local function serialize (obj)
    if type(obj) == "number" or type(obj) == "boolean" then
        return tostring(obj)
    elseif type(obj) == "string" then
        return string.format("%q", obj)
    elseif type(obj) == "table" then
        local string = "{"
        for k,v in pairs(obj) do
            string = string .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ","
        end
        return string .. "}"
    else
        error("cannot serialize a " .. type(obj))
    end
end


--- return the module
return {
    Set = Set,
    concat_lists,
    serialize = serialize
}