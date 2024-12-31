--Config
PROTOCOL_NAME = "EnderAlchemist"
PYLON_NAME = "Main Pylon"
USERNAME = 'astracerus'

--Constants
POTION_FILTER_NAME = 'pylons:potion_filter'
LIST_EFFECTS = 'listEffects'
ENABLE_EFFECT = 'enableEffect'
DISABLE_EFFECT = 'disableEffect'
LOOKUP = "lookup"

--Globals
pylon = peripheral.wrap("left")
barrel = peripheral.wrap("right")


--core logic
function disableEffect(effectName)
    for slot, _ in pairs(pylon.list()) do
        if string.lower(pylon.getItemDetail(slot).displayName) == string.lower(effectName) then
            local count = pylon.pushItems(peripheral.getName(barrel), slot) --done this way to avoid nbt filter not being respected bug
            return count == 1
        end
    end
    return false
end

function enableEffect(effectName)
    for slot, _ in pairs(barrel.list()) do
        if string.lower(barrel.getItemDetail(slot).displayName) == string.lower(effectName) then
            local count = pylon.pullItems(peripheral.getName(barrel), slot)
            return count == 1
        end
    end
    return false
end

function listAllEffects() 
    local retList = {}
    for slot, _ in pairs(pylon.list()) do
        table.insert(retList, {name = pylon.getItemDetail(slot).displayName, active = true})
    end
    for slot, _ in pairs(barrel.list()) do
        table.insert(retList, {name = barrel.getItemDetail(slot).displayName, active = false})
    end
    table.sort(retList, function(a,b) return a.name < b.name end)
    return retList
end

function listActiveEffects()
    local retList = {}
    for slot, _ in pairs(pylon.list()) do
        table.insert(retList, pylon.getItemDetail(slot).displayName)
    end
    table.sort(retList)
    return retList
end

function listDisabledEffects()
    local retList = {}
    for slot, _ in pairs(barrel.list()) do
        table.insert(retList, out_of_use_storage.getItemDetail(slot).displayName)
    end
    table.sort(retList)
    return retList
end


--server logic
function getEffectNetworkRepresentation(name, active)
    if active then
        return name .. ":A"
    else 
        return name .. ":I"
    end
end

function listAllEffectsAPI()
    local effects = listAllEffects()
    msg = ""
    for _, effect in ipairs(effects) do
        msg = msg .. "," .. getEffectNetworkRepresentation(effect.name, effect.active)
    end
    msg = string.sub(msg, 2, string.len(msg))
    return msg
end

function enableEffectAPI(effectName)
    if enableEffect(effectName) then
        return effectName .. ":A"
    else
        return effectName .. ":I"
    end
end

function disableEffectAPI(effectName)
    if disableEffect(effectName) then
        return effectName .. ":I"
    else
        return effectName .. ":A"
    end
end

rednet.open('back') -- must be an ender modem
while true do 
    -- print("Waiting for message")
    local id, message = rednet.receive(PROTOCOL_NAME)
    if string.sub(message, 1, string.len(LOOKUP)) == LOOKUP then
        if string.find(message, ':') == nil then
            rednet.send(id, "No Username Specified", ':')
        else
            idx = string.find(message, ":") + 1
            if string.sub(message, idx, string.len(message))== USERNAME then
                rednet.send(id, PYLON_NAME, PROTOCOL_NAME)
            end
        end
    else 
    -- print("Received message -> " .. message)
        resp = "Unknown API Call"
        if message == LIST_EFFECTS then
            resp = listAllEffectsAPI()
        elseif string.sub(message, 1, string.len(ENABLE_EFFECT)) == ENABLE_EFFECT then
            if string.find(message, ':') == nil then
                resp = "No effect specified"
            else
                idx = string.find(message, ":") + 1
                resp = enableEffectAPI(string.sub(message, idx, string.len(message)))
            end
        elseif string.sub(message, 1, string.len(DISABLE_EFFECT)) == DISABLE_EFFECT then
            if string.find(message, ':') == nil then
                resp = "No effect specified"
            else
                idx = string.find(message, ":") + 1
                resp = disableEffectAPI(string.sub(message, idx, string.len(message)))
            end
        end
        sent = rednet.send(id, resp, PROTOCOL_NAME)
    end
end
