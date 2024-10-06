local events = require("utils.events")
local stoarge = require("storage")
local log  = require("libs.log")

-- List of all attached modems
local modems = {}

local running = true


local function getModems()
    modems = {peripheral.find("modem", rednet.open)}
end

local function initRednet()
    rednet.host("stoarge", "server")
    rednet.host("dns", os.getComputerID)
end

local function closeRednet()
    rednet.unhost("storage")
    rednet.unhost("dns")
    rednet.close()
end

local function handlePeripheralChange()
    log.info("Peripheral attached/ detached. Restarting rednet...")
    getModems()
end

local function handleDNS(sender, message)
    
end

local function handleRednetMessage(event, sender, message, protocol)
    if protocol ~= nil then
        print("Received message from %d with protocol %s and message %s"):format(sender, protocol, tostring(message))
    else
        print("Received message from %d with message %s"):format(sender, tostring(message))
    end

    if protocol == "dns" then
        handleDNS(sender, message)
    end
end

local function handleTerminate()
    log.info("Shuting down server...")
    closeRednet()
    running = false
end

events.addHandler("peripheral", handlePeripheralChange)
events.addHandler("peripheral_detach", handlePeripheralChange)
events.addHandler("rednet_message", handleRednetMessage)
events.addHandler("terminate", handleTerminate)


while running do
    events.pullEventRaw()
end