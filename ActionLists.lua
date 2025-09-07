--[[
    ■■■■■ ActionLists
    ■   ■ Author: @sh1zok_was_here
    ■■■■  v1.1

MIT License

Copyright (c) 2025 Sh1zok

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--

--#region Modifying pages metatable
local pagesMetatable = figuraMetatables.Page -- Link to the pages metatable. If something here was changed, it will change in figurаMetatable.Page too
local pagesOriginalIndexMethod = pagesMetatable.__index -- Save the original __index method for future use
local pagesCustomMethods = {} -- Custom methods for pages

-- Checks the custom methods table first. If it finds something, it returns that. If it doesn't it uses the original __index method to find something instead.
function pagesMetatable:__index(key)
    if pagesCustomMethods[key] then return pagesCustomMethods[key] end
    return pagesOriginalIndexMethod(self, key)
end
--#endregion

--#region The action list logic
function pagesCustomMethods:newActionList()
    --[[
        Setting up some variables
    ]]--
    local interface = {} -- The interface through which interactions with the action list are performed
    local userdata = self:newAction() -- The button that appears in the action wheel
    local selectedActionIndex = 1 -- Index of the selected action
    local visualSize = 7 -- Length of the visible part of the list on the screen
    local actionListTitle = "" -- Title of actionList. Can be a string or a table(for JSON)
    local defaultColor, defaultHoverColor, defaultTexture, defaultHoverTexture, defaultItem, defaultHoverItem -- Default stuff are only visible when the selected action does not have any of the things listed here
    local selectedActionColor, actionListColor = vec(1, 1, 1), vec(0.75, 0.75, 0.75)
    local actionList = { -- The action list itself
        [1] = {
            title = "This action list is empty...",
            onRightClick = function() host:setActionbar("Sh1zok was here ;3") end -- Easter egg :p
        }
    }

    -- New title for button(userdata) maker
    local function makeNewTitle()
        local title -- New title for button
        if type(actionListTitle) == "string" then title = {{text = actionListTitle}} end
        if type(actionListTitle) == "table" then title = {actionListTitle} end

        -- Calculating visual indexes limits
        local topVisualIndex = selectedActionIndex - math.floor(visualSize / 2)
        local bottomVisualIndex = selectedActionIndex + math.floor(visualSize / 2)
        if bottomVisualIndex - topVisualIndex > visualSize then bottomVisualIndex = bottomVisualIndex - 1 end
        if topVisualIndex < 1 then
            topVisualIndex = 1
            bottomVisualIndex = visualSize
        end
        if bottomVisualIndex > #actionList then
            bottomVisualIndex = bottomVisualIndex - (bottomVisualIndex - #actionList) + 1
            topVisualIndex = bottomVisualIndex - visualSize
        end

        -- Adding a action list under the button title
        for index, value in ipairs(actionList) do
            if index >= topVisualIndex and index <= bottomVisualIndex then
                if index == selectedActionIndex then
                    table.insert(title, {text = "\n " .. "=> " .. value.title, color = "#" .. vectors.rgbToHex(selectedActionColor)})
                else
                    table.insert(title, {text = "\n " .. index .. ". " .. value.title, color = "#" .. vectors.rgbToHex(actionListColor)})
                end
            end
        end

        return toJson(title) -- Returns JSON
    end
    userdata.setTitle(userdata, makeNewTitle()) -- Making entry title



    --[[
        Interface setters: List&Title appearance
            After every setting title getting an update. Sometimes it can eat too many resources. 
            If there is too much init instructions you can choose to don't update title with true in optional parameter.
    ]]--
    function interface:setTitle(title, shouldntMakeNewTitle)
        if title == nil then title = "" end
        if not (type(title) == "string" or type(title) == "table") then error("Invalid argument to function setTitle. Expected string or Table, but got " .. type(table), 2) end
        actionListTitle = title

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:title(title, shouldntMakeNewTitle) return interface:setTitle(title, shouldntMakeNewTitle) end -- Alias

    function interface:setActionList(table, shouldntMakeNewTitle)
        if table == nil then table = {} end
        if type(table) ~= "table" then error("Invalid argument to function setActionList. Expected Table, but got " .. type(table), 2) end
        actionList = table

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:actionList(table, shouldntMakeNewTitle) return interface:setActionList(table, shouldntMakeNewTitle) end -- Alias

    function interface:setActionListColor(color, shouldntMakeNewTitle)
        if color == nil then color = vec(0, 0, 0) end
        if type(color) ~= "Vector3" then error("Invalid argument to function setActionListColor. Expected Vector3, but got " .. type(color), 2) end
        actionListColor = color

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:actionListColor(color, shouldntMakeNewTitle) return interface:setActionListColor(color, shouldntMakeNewTitle) end -- Alias

    function interface:setSelectedActionColor(color, shouldntMakeNewTitle)
        if color == nil then color = vec(0, 0, 0) end
        if type(color) ~= "Vector3" then error("Invalid argument to function setSelectedActionColor. Expected Vector3, but got " .. type(color), 2) end
        selectedActionColor = color

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:selectedActionColor(color, shouldntMakeNewTitle) return  interface:setSelectedActionColor(color, shouldntMakeNewTitle) end -- Alias

    function interface:setSelectedActionIndex(index, shouldntMakeNewTitle)
        if index == nil then index = 1 end
        if type(index) ~= "number" then error("Invalid argument to function setSelectedAction. Expected number, but got " .. type(index), 2) end
        selectedActionIndex = index

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:selectedActionIndex(index, shouldntMakeNewTitle) return interface:setSelectedAction(index, shouldntMakeNewTitle) end -- Alias

    function interface:setVisualSize(size, shouldntMakeNewTitle)
        if size == nil then size = 7 end
        if type(size) ~= "number" then error("Invalid argument to function setVisualSize. Expected number, but got " .. type(index), 2) end
        visualSize = size

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:visualSize(size, shouldntMakeNewTitle) return interface:setVisualSize(size, shouldntMakeNewTitle) end -- Alias



    --[[
        Interface setters: Button(userdata) appearance
    ]]--
    function interface:setColor(color)
        if color == nil then color = vec(0, 0, 0) end
        if type(color) ~= "Vector3" then error("Invalid argument to function setColor. Expected Vector3, but got " .. type(color), 2) end
        defaultColor = color

        userdata:setColor(actionList[selectedActionIndex].color or defaultColor)
        return interface -- Returns self for chaining
    end
    function interface:color(color) return interface:setColor(color) end -- Alias

    function interface:setHoverColor(color)
        if color == nil then color = vec(0, 0, 0) end
        if type(color) ~= "Vector3" then error("Invalid argument to function setHoverColor. Expected Vector3, but got " .. type(color), 2) end
        defaultHoverColor = color

        userdata:setHoverColor(actionList[selectedActionIndex].hoverColor or defaultHoverColor)
        return interface -- Returns self for chaining
    end
    function interface:hoverColor(color) return interface:setHoverColor(color) end -- Alias

    function interface:setItem(item)
        if item == nil then item = "minecraft:air" end
        if type(item) ~= "string" then error("Invalid argument to function setItem. Expected string, but got " .. type(item), 2) end
        defaultItem = item

        userdata:setItem(actionList[selectedActionIndex].item or defaultItem)
        return interface -- Returns self for chaining
    end
    function interface:item(item) return interface:setItem(item) end -- Alias

    function interface:setHoverItem(item)
        if item == nil then item = defaultItem end
        if type(item) ~= "string" then error("Invalid argument to function setHoverItem. Expected string, but got " .. type(item), 2) end
        defaultHoverItem = item

        userdata:setHoverItem(actionList[selectedActionIndex].hoverItem or defaultHoverItem)
        return interface -- Returns self for chaining
    end
    function interface:hoverItem(item) return interface:setHoverItem(item) end -- Alias

    function interface:setTexture(texture)
        if type(texture) ~= "Texture" then error("Invalid argument to function setTexture. Expected Texture, but got " .. type(texture), 2) end
        defaultTexture = texture

        userdata:setTexture(actionList[selectedActionIndex].texture or defaultTexture)
        return interface -- Returns self for chaining
    end
    function interface:texture(texture) return interface:setTexture(texture) end -- Alias

    function interface:setHoverTexture(texture)
        if type(texture) ~= "Texture" then error("Invalid argument to function setHoverItem. Expected Texture, but got " .. type(texture), 2) end
        defaultHoverTexture = texture

        userdata:setHoverTexture(actionList[selectedActionIndex].hoverTexture or defaultHoverTexture)
        return interface -- Returns self for chaining
    end
    function interface:hoverTexture(texture) return interface:setHoverTexture(texture) end -- Alias



    --[[
        Interface getters
    ]]--
    function interface:getUserdata() return userdata end
    function interface:getActionList() return actionList end
    function interface:getTitle() return actionListTitle end
    function interface:getVisualSize() return visualSize end
    function interface:getColor() return defaultColor end
    function interface:getHoverColor() return defaultHoverColor end
    function interface:getSelectedActionIndex() return selectedActionIndex end
    function interface:getSelectedActionColor() return selectedActionColor end
    function interface:getActionListColor() return actionListColor end



    --[[
        Button(userdata) custom logic
    ]]--
    userdata:setOnLeftClick(function() if actionList[selectedActionIndex] and type(actionList[selectedActionIndex].onLeftClick) == "function" then actionList[selectedActionIndex]:onLeftClick() end end)
    userdata:setOnRightClick(function() if actionList[selectedActionIndex] and type(actionList[selectedActionIndex].onRightClick) == "function" then actionList[selectedActionIndex]:onRightClick() end end)
    userdata:setOnScroll(function(scrollDirection)
        if not actionList[selectedActionIndex] then return end -- Prevents errors when the list is REALLY empty

        if scrollDirection > 0 and selectedActionIndex <= 1 then selectedActionIndex = #actionList + 1 end -- Preventing list out of bounds past the beginning of a list
        if scrollDirection < 0 and selectedActionIndex >= #actionList then selectedActionIndex = 0 end -- Preventing list out of bounds past end of list
        selectedActionIndex = selectedActionIndex - scrollDirection

        if type(actionList[selectedActionIndex].onSelect) == "function" then actionList[selectedActionIndex]:onSelect(scrollDirection) end

        if actionList[selectedActionIndex].color or defaultColor then userdata:setColor(actionList[selectedActionIndex].color or defaultColor) end
        if actionList[selectedActionIndex].hoverColor or defaultHoverColor then userdata:setHoverColor(actionList[selectedActionIndex].hoverColor or defaultHoverColor) end
        if actionList[selectedActionIndex].item or defaultItem then userdata:setItem(actionList[selectedActionIndex].item or defaultItem) end
        if actionList[selectedActionIndex].hoverItem or defaultHoverItem then userdata:setHoverItem(actionList[selectedActionIndex].hoverItem or defaultHoverItem) end
        if actionList[selectedActionIndex].texture or defaultTexture then userdata:setTexture(actionList[selectedActionIndex].texture or defaultTexture) end
        if actionList[selectedActionIndex].hoverTexture or defaultHoverTexture then userdata:setHoverTexture(actionList[selectedActionIndex].hoverTexture or defaultHoverTexture) end

        userdata.setTitle(userdata, makeNewTitle())
    end)



    --[[
        Returning an interface
    ]]--
    return interface
end
--#endregion
