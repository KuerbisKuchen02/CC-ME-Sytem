---Convert a list to a Set. Sets allow you to easily check 
---if a value is present in a list
---@param list table List which should be converted to a set
---@return table Set set with the provided items
function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

--- Returns a new list containing all entries from both lists
---@param ... table lists 
---@return table list new list with all entries
local function concat_lists(...)
    local list = {}
    for _,l in ipairs({...}) do
        for i = 1, #l do
            table.insert(list, l[i])
        end
    end
    return list
end

return {Set = Set, concat_lists}