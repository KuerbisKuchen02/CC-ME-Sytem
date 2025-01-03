--- Class system for Lua

--- Create a new object of a class
---
--- @param c table the class
--- @param ...? any the arguments for the constructor (optional)
--- @return table object the new object
local function new (c, ...)
    assert(type(c) == "table", "Class must be a table")

    local o = {}
    setmetatable(o, c)

    if c.constructor then
        c.constructor(o, ...)
    end

    return o
end


--- Invoke a parent method that is overriden by the current class
---
--- @param object table the object
--- @param methode function the method name
--- @param ...? any the arguments for the method (optional)
--- @return any values the return values of the method
local function super (object, methode, ...)
    assert(type(object) == "table", "Object must be a table")
    assert(type(methode) == "string", "Method must be a string")
    -- store the current scope of the super method for recursive super calls,
    -- because the original object must be passed to the super method to access its attributes
    local current = object.__superScope
    local next
    if current then
        next = getmetatable(current).__index
    else 
        next = getmetatable(getmetatable(object)).__index
    end

    local result
    while next do
        if next[methode] then
            -- call the super method with the original object but with the scope of the super method
            object.__superScope = next
            result = {pcall(next[methode], object, ...)}
            object.__superScope = current
            break
        end
        next = getmetatable(next).__index
    end

    if result == nil then
        error("No super method found", 2)
    elseif table.remove(result, 1) then
        return table.unpack(result)
    else
        error(result[1], 2)
    end
end


--- check if an object is an instance of a class
---
--- @param object table the object to verify
--- @param class table the class to check against
--- @return boolean isInstance true if the object is an instance of the class
local function instanceOf (object, class)
    assert(type(object) == "table", "Object must be a table")
    assert(type(class) == "table", "Class must be a table")

    local c = getmetatable(object).__index
    while c do 
        if c == class then
            return true
        end
        c = getmetatable(c).__index
    end
    return false
end


--- Object destructor handler
---
--- This is the _gc implementation and should not be called manually
---
--- @param object table the object
local function finalizer (object)
    assert(type(object) == "table", "Object must be a table")

    if object.destructor then
        object:destructor()
    end
end


--- Class table factory
---
--- @param parent? table class to inherit from (optional)
--- @return table class the class table
local function class (parent)
    assert(parent == nil or type(parent) == "table", "Parent must be a table or nil")

    local c = {}
    local mt = {}
    
    if parent then
        c.super = super
        mt.__index = parent
    end

    c.new = new
    mt.__gc = finalizer
    mt.__call = new

    c.__index = c
    setmetatable(c, mt)

    return c
end


--- return the module
return {
    class = class,
    new = new,
    super = super,
    instanceOf = instanceOf
}