--[[
    ■■■■■ ActionsLists
    ■   ■ Author: @sh1zok_was_here
    ■■■■  v1.0
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

--#region The actions list logic
function pagesCustomMethods:newActionsList()
    --[[
        Setting up some variables
    ]]--
    local interface = {} -- The interface through which interactions with the actions list are performed
    local userdata = self:newAction() -- The button that appears in the action wheel
    local selectedActionIndex = 1 -- Index of the selected action
    local visualSize = 7 -- Length of the visible part of the list on the screen
    local actionsListTitle = "" -- Title of actionsList. Can be a string or a table(for JSON)
    local defaultColor, defaultHoverColor, defaultTexture, defaultHoverTexture, defaultItem, defaultHoverItem -- Default stuff are only visible when the selected action does not have any of the things listed here
    local selectedActionColor, actionsListColor = vec(1, 1, 1), vec(0.75, 0.75, 0.75)
    local actionsList = { -- The actions list itself
        [1] = {
            title = "This actions list is empty...",
            onRightClick = function() host:setActionbar("Sh1zok was here ;3") end -- Easter egg :p
        }
    }

    -- New title for button(userdata) maker
    local function makeNewTitle()
        local title -- New title for button
        if type(actionsListTitle) == "string" then title = {{text = actionsListTitle}} end
        if type(actionsListTitle) == "table" then title = {actionsListTitle} end

        -- Calculating visual indexes limits
        local topVisualIndex = selectedActionIndex - math.floor(visualSize / 2)
        local bottomVisualIndex = selectedActionIndex + math.floor(visualSize / 2)
        if bottomVisualIndex - topVisualIndex > visualSize then bottomVisualIndex = bottomVisualIndex - 1 end
        if topVisualIndex < 1 then
            topVisualIndex = 1
            bottomVisualIndex = visualSize
        end
        if bottomVisualIndex > #actionsList then
            bottomVisualIndex = bottomVisualIndex - (bottomVisualIndex - #actionsList) + 1
            topVisualIndex = bottomVisualIndex - visualSize
        end

        -- Adding a actions list under the button title
        for index, value in ipairs(actionsList) do
            if index >= topVisualIndex and index <= bottomVisualIndex then
                if index == selectedActionIndex then
                    table.insert(title, {text = "\n " .. "=> " .. value.title, color = "#" .. vectors.rgbToHex(selectedActionColor)})
                else
                    table.insert(title, {text = "\n " .. index .. ". " .. value.title, color = "#" .. vectors.rgbToHex(actionsListColor)})
                end
            end
        end

        return toJson(title) -- Return JSON
    end
    userdata.setTitle(userdata, makeNewTitle()) -- Making entry title



    --[[
        Interface setters: List&Title appearance
            After every setting title getting an update. Sometimes it can eat too many resources. 
            If there is too much init instructions you can choose to don't update title with true in optional parameter.
    ]]--
    function interface:setTitle(title, shouldntMakeNewTitle)
        if not (type(title) == "string" or type(title) == "table") then error("Invalid argument to function setTitle. Expected string or Table, but got " .. type(table), 2) end
        actionsListTitle = title

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:title(title, shouldntMakeNewTitle) return interface:setTitle(title, shouldntMakeNewTitle) end -- Alias

    function interface:setActionsList(table, shouldntMakeNewTitle)
        if type(table) ~= "table" then error("Invalid argument to function setActionsList. Expected Table, but got " .. type(table), 2) end
        actionsList = table

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:actionsList(table, shouldntMakeNewTitle) return interface:setActionsList(table, shouldntMakeNewTitle) end -- Alias

    function interface:setActionsListColor(rgb, shouldntMakeNewTitle)
        if type(rgb) ~= "Vector3" then error("Invalid argument to function setActionsListColor. Expected Vector3, but got " .. type(rgb), 2) end
        actionsListColor = rgb

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:actionsListColor(rgb, shouldntMakeNewTitle) return interface:setActionsListColor(rgb, shouldntMakeNewTitle) end -- Alias

    function interface:setSelectedActionColor(rgb, shouldntMakeNewTitle)
        if type(rgb) ~= "Vector3" then error("Invalid argument to function setSelectedActionColor. Expected Vector3, but got " .. type(rgb), 2) end
        selectedActionColor = rgb

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:selectedActionColor(rgb, shouldntMakeNewTitle) return  interface:setSelectedActionColor(rgb, shouldntMakeNewTitle) end -- Alias

    function interface:setSelectedActionIndex(index, shouldntMakeNewTitle)
        if type(index) ~= "number" then error("Invalid argument to function setSelectedAction. Expected number, but got " .. type(index), 2) end
        selectedActionIndex = index

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:selectedActionIndex(index, shouldntMakeNewTitle) return interface:setSelectedAction(index, shouldntMakeNewTitle) end -- Alias

    function interface:setVisualSize(size, shouldntMakeNewTitle)
        if type(size) ~= "number" then error("Invalid argument to function setVisualSize. Expected number, but got " .. type(index), 2) end
        visualSize = size

        if not shouldntMakeNewTitle then userdata.setTitle(userdata, makeNewTitle()) end
        return interface -- Returns self for chaining
    end
    function interface:visualSize(size, shouldntMakeNewTitle) return interface:setVisualSize(size, shouldntMakeNewTitle) end -- Alias



    --[[
        Interface setters: Button(userdata) appearance
    ]]--
    function interface:setColor(rgb)
        if type(rgb) ~= "Vector3" then error("Invalid argument to function setColor. Expected Vector3, but got " .. type(rgb), 2) end
        defaultColor = rgb

        userdata:setColor(actionsList[selectedActionIndex].color or defaultColor)
        return interface -- Returns self for chaining
    end
    function interface:color(rgb) return interface:setColor(rgb) end -- Alias

    function interface:setHoverColor(rgb)
        if type(rgb) ~= "Vector3" then error("Invalid argument to function setHoverColor. Expected Vector3, but got " .. type(rgb), 2) end
        defaultHoverColor = rgb

        userdata:setHoverColor(actionsList[selectedActionIndex].hoverColor or defaultHoverColor)
        return interface -- Returns self for chaining
    end
    function interface:hoverColor(rgb) return interface:setHoverColor(rgb) end -- Alias

    function interface:setItem(minecraftID)
        if type(minecraftID) ~= "string" then error("Invalid argument to function setItem. Expected string, but got " .. type(minecraftID), 2) end
        defaultItem = minecraftID

        userdata:setItem(actionsList[selectedActionIndex].item or defaultItem)
        return interface -- Returns self for chaining
    end
    function interface:item(minecraftID) return interface:setItem(minecraftID) end -- Alias

    function interface:setHoverItem(minecraftID)
        if type(minecraftID) ~= "string" then error("Invalid argument to function setHoverItem. Expected string, but got " .. type(minecraftID), 2) end
        defaultHoverItem = minecraftID

        userdata:setHoverItem(actionsList[selectedActionIndex].hoverItem or defaultHoverItem)
        return interface -- Returns self for chaining
    end
    function interface:hoverItem(minecraftID) return interface:setHoverItem(minecraftID) end -- Alias

    function interface:setTexture(texture)
        if type(texture) ~= "Texture" then error("Invalid argument to function setTexture. Expected Texture, but got " .. type(texture), 2) end
        defaultTexture = texture

        userdata:setTexture(actionsList[selectedActionIndex].texture or defaultTexture)
        return interface -- Returns self for chaining
    end
    function interface:texture(texture) return interface:setTexture(texture) end -- Alias

    function interface:setHoverTexture(texture)
        if type(texture) ~= "Texture" then error("Invalid argument to function setHoverItem. Expected Texture, but got " .. type(texture), 2) end
        defaultHoverTexture = texture

        userdata:setHoverTexture(actionsList[selectedActionIndex].hoverTexture or defaultHoverTexture)
        return interface -- Returns self for chaining
    end
    function interface:hoverTexture(texture) return interface:setHoverTexture(texture) end -- Alias



    --[[
        Interface getters
    ]]--
    function interface:getUserdata() return userdata end
    function interface:getActionsList() return actionsList end
    function interface:getTitle() return actionsListTitle end
    function interface:getVisualSize() return visualSize end
    function interface:getColor() return defaultColor end
    function interface:getHoverColor() return defaultHoverColor end
    function interface:getItem() return defaultItem end
    function interface:getHoverItem() return defaultHoverItem end
    function interface:getTexture() return defaultTexture end
    function interface:getHoverTexture() return defaultHoverTexture end
    function interface:getSelectedActionIndex() return selectedActionIndex end
    function interface:getSelectedActionColor() return selectedActionColor end
    function interface:getActionsListColor() return actionsListColor end



    --[[
        Button(userdata) custom logic
    ]]--
    userdata:setOnLeftClick(function() if type(actionsList[selectedActionIndex].onLeftClick) == "function" then actionsList[selectedActionIndex]:onLeftClick() end end)
    userdata:setOnRightClick(function() if type(actionsList[selectedActionIndex].onRightClick) == "function" then actionsList[selectedActionIndex]:onRightClick() end end)
    userdata:setOnScroll(function(scrollDirection)
        if scrollDirection < 0 then -- Scrolling up
            if selectedActionIndex <= 1 then selectedActionIndex = #actionsList + 1 end
            selectedActionIndex = selectedActionIndex - 1
        else -- Scrolling down
            if selectedActionIndex >= #actionsList then selectedActionIndex = 0 end
            selectedActionIndex = selectedActionIndex + 1
        end

        if type(actionsList[selectedActionIndex].onSelect) == "function" then actionsList[selectedActionIndex]:onSelect() end

        makeNewTitle()
    end)



    --[[
        Returning an interface
    ]]--
    return interface
end
--#endregion
