--- create a new file with the given name
--- @param file_name string
local function createFile(file_name)
    fs.open(file_name, "w").close()
end

---read the content of the file with the given name
---if the file doesnt exists returns an empty string
---@param file_name string
---@return string
local function readFile(file_name)
    if not fs.exists(file_name) then
        return ""
    end
    local file = fs.open(file_name, "r")
    local content = file.readAll()
    file.close()
    return content
end

---write text to a file with given name
---overwrites existing file or creates a new one
---@param file_name string
---@param text string
local function writeFile(file_name, text)
    fs.delete(file_name)
    local file = fs.open(file_name, "w")
    file.write(text)
    file.close()
end

---get object from given file
---@param name string
---@return table
local function getObject(name)
    local content = readFile(name)
    return textutils.unserialise(content)
end

---save object to a file with given name
---@param name string
---@param object table
local function saveObject(name, object)
    writeFile(name, textutils.serialise(object))
end


-- export all functions
return {
    createFile = createFile,
    readFile = readFile,
    writeFile = writeFile,
    getObject = getObject,
    saveObject = saveObject
}

