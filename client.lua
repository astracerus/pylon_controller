PROTOCOL_NAME = "EnderAlchemist"
USERNAME = 'astracerus'

LIST_EFFECTS = 'listEffects'
ENABLE_EFFECT = 'enableEffect:'
DISABLE_EFFECT = 'disableEffect:'
LOOKUP = "lookup:"

pylonIds = {}
pylonList = {} 
active_pylon = ""

effectList = {} 
effectActiveDict= {}

buttons = {}

LOADING_STRING = "Loading"
width, height = term.getSize()
while string.len(LOADING_STRING) < width do
    LOADING_STRING = " " .. LOADING_STRING .. " "
end

function discoverPylons()
    rednet.broadcast(LOOKUP .. USERNAME, PROTOCOL_NAME)
    local id, message
    pylonIds = {}
    pylonList = {} 
    repeat 
        id, message = rednet.receive(PROTOCOL_NAME, 3)
        if id then
            pylonIds[message] = id
            table.insert(pylonList, message)
        end
    until not id
    table.sort(pylonList)
end

function refeshEffectsList()
    effectList = {} 
    effectActiveDict = {}

    rednet.send(pylonIds[active_pylon], LIST_EFFECTS, PROTOCOL_NAME)
    local id, effects = rednet.receive(PROTOCOL_NAME)
    for effect in string.gmatch(effects, "[^,]+") do
        local effectName = string.sub(effect, 1, string.len(effect)-2)
        local isActive = string.sub(effect, string.len(effect), string.len(effect)) == "A"
        table.insert(effectList, effectName)
        effectActiveDict[effectName] = isActive
    end
    table.sort(effectList)
end

function enableEffect(effectName)
    rednet.send(pylonIds[active_pylon], ENABLE_EFFECT .. effectName, PROTOCOL_NAME)
    local id, response = rednet.receive(PROTOCOL_NAME)
    if string.sub(response, string.len(response), string.len(response)) == "A" then
        effectActiveDict[effectName] = true
    else
        effectActiveDict[effectName] = false
    end
end

function disableEffect(effectName)
    rednet.send(pylonIds[active_pylon], DISABLE_EFFECT .. effectName, PROTOCOL_NAME)
    local id, response = rednet.receive(PROTOCOL_NAME)
    if string.sub(response, string.len(response), string.len(response)) == "A" then
        effectActiveDict[effectName] = true
    else
        effectActiveDict[effectName] = false
    end
end
        

local Button = {
    x = 1,
    y = 1,
    length = 1,
    text = "",
    color = colors.black,
    textColor = colors.white,
    onClick = function(self) end,
    inArea = function(self,x,y)
        return self.y == y and (x < self.x + self.length and x >= self.x)
    end,
    draw = function(self)
        term.setBackgroundColor(self.color)
        term.setCursorPos(self.x, self.y)
        term.setTextColor(self.textColor)
        --get the text length right
        display_text = ""
        if string.len(self.text) > self.length then
            display_text = string.sub(self.text, 1, self.length)
        elseif string.len(self.text) == self.length then
            display_text = self.text
        else 
            display_text = self.text
            while string.len(display_text) < self.length do
                display_text = " " .. display_text .. " "
            end
            if string.len(display_text) > self.length then
                display_text = string.sub(display_text, 1, string.len(display_text) - 1)
            end
        end
        term.write(display_text) 
    end
}

function Button:new(o)
    o = o or {} -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function displayPylonList()
    width, height = term.getSize()
    buttons = {} 
    local topButton = Button:new({length=width, text="Pylons",x=1,y=1})
    table.insert(buttons, topButton)

    for i=1,9 do
        if pylonList[i] ~= nil then
            local pylonButton = Button:new({x=1, y=i+2, length=width, text=pylonList[i], onClick=function(self) active_pylon=self.text refeshEffectsList() end})
            table.insert(buttons, pylonButton)
        end
    end

    local refreshButton = Button:new({x=1, y=height, length=width,text='Refresh', onClick=function(self) discoverPylons() end})
    table.insert(buttons, refreshButton)
end

function displayEffectsList()
    width, height = term.getSize()
    buttons = {} 
    local topButton = Button:new({length=width, text=active_pylon,x=1,y=1})
    table.insert(buttons, topButton)

    for i=1,9 do
        if effectList[i] ~= nil then
            local textColor, onClick
            if effectActiveDict[effectList[i]] then
                textColor = colors.green
                onClick = function(self) disableEffect(self.text) end
            else
                textColor = colors.orange
                onClick = function(self) enableEffect(self.text) end
            end
            local effectButton = Button:new({x=1, y=i+2, length=width, text=effectList[i], textColor = textColor, onClick=onClick})
            table.insert(buttons, effectButton)
        end
    end

    local refreshButton = Button:new({x=14, y=height, length=12,text='Refresh', onClick=function(self) refeshEffectsList() end})
    table.insert(buttons, refreshButton)

    local backButton = Button:new({x=1,y=height, length=12, text='Back', onClick=function(self) active_pylon = "" end})
    table.insert(buttons, backButton)

end

function drawLoadingScreen()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setCursorPos(1, 1)
    term.write(LOADING_STRING)
end

function main()
    rednet.open('back')
    drawLoadingScreen()
    discoverPylons()
    while true do
        if active_pylon == "" then
            displayPylonList()
        else
            displayEffectsList()
        end

        term.clear()
        for _, button in ipairs(buttons) do
            button:draw()
        end

        local event, button, x, y = os.pullEvent("mouse_click")
        drawLoadingScreen()
        for _,button in ipairs(buttons) do
            if button:inArea(x,y) then
                button:onClick()
            end
        end
    end
end

main()



