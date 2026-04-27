GOMove = {Frames = {}, Inputs = {}}

function GOMove:Update()
    for k, Frame in ipairs(GOMove.Frames) do
        if(Frame.Update) then
            Frame:Update()
        end
    end
end

function GOMove:CreateFrame(name, width, height, DataTable, both)
    local Frame = CreateFrame("Frame", name, UIParent)
    Frame:SetMovable(true)
    Frame:EnableMouse(true)
    Frame:SetClampedToScreen(true);
    Frame:RegisterForDrag("LeftButton")
    Frame:SetScript("OnDragStart", Frame.StartMoving)
    Frame:SetScript("OnDragStop", Frame.StopMovingOrSizing)
    Frame:SetScript("OnHide", Frame.StopMovingOrSizing)
    Frame:SetSize(width, height)
    Frame:SetPoint("CENTER")
    Frame.ButtonCount = math.floor((height-32)/16)
    Frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    local NameFrame = CreateFrame("Frame", name.."_Name", Frame)
    NameFrame:SetHeight(16)
    NameFrame:SetWidth(width-16)
    NameFrame.text = NameFrame:CreateFontString()
    NameFrame.text:SetFont("Fonts\\MORPHEUS.ttf", 14)
    NameFrame.text:SetTextColor(0.8, 0.2, 0.2)
    NameFrame.text:SetJustifyH("LEFT")
    NameFrame.text:SetAllPoints()
    NameFrame.text:SetText(name:gsub("_", " "))
    NameFrame:SetPoint("TOPLEFT", Frame, "TOPLEFT", 8, -8)
    NameFrame:Show()
    Frame.NameFrame = NameFrame
    local CloseButton = CreateFrame("Button", name.."_CloseButton", Frame)
    CloseButton:SetSize(25, 25)
    CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
    CloseButton:SetPoint("TOPRIGHT", Frame, "TOPRIGHT", 0, 0)
    CloseButton:SetScript("OnClick", function() Frame:Hide() end)

    if(DataTable) then
        Frame.DataTable = DataTable
        function Frame:Update()
            local maxValue = #DataTable
            FauxScrollFrame_Update(self.ScrollBar, maxValue, self.ButtonCount, 16, nil, nil, nil, nil, nil, nil, true)
            local offset = FauxScrollFrame_GetOffset(self.ScrollBar)
            for idx = 1, self.ButtonCount do
                local value = idx + offset
                if value <= maxValue then
                    local Btn = self.Buttons[idx]
                    local Label = DataTable[value][1]
                    if(DataTable.NameWidth and #DataTable[value][1] > DataTable.NameWidth) then
                        Label = DataTable[value][1]:sub(0, DataTable.NameWidth-2)..".."
                    end
                    if(not both) then
                        Btn:SetText(Label)
                    else
                        Btn:SetText(DataTable[value][2].." "..Label)
                    end
                    Btn.MiscButton:Show()
                    Btn:Show()
                else
                    self.Buttons[idx]:Hide()
                    self.Buttons[idx].MiscButton:Hide()
                end
                if(Frame.UpdateScript) then
                    Frame:UpdateScript(idx)
                end
            end
        end

        local ScrollBar = CreateFrame("ScrollFrame", "$parent_ScrollBar", Frame, "FauxScrollFrameTemplate")
        ScrollBar:SetPoint("TOPLEFT", 0, -24)
        ScrollBar:SetPoint("BOTTOMRIGHT", -30, 8)

        ScrollBar:SetScript("OnVerticalScroll", function(self, offset)
            self.offset = math.floor(offset / 16 + 0.5)
            Frame:Update()
        end)

        ScrollBar:SetScript("OnShow", function()
            Frame:Update()
        end)

        Frame.ScrollBar = ScrollBar

        local Buttons = setmetatable({}, { __index = function(t, i)
            local Button = CreateFrame("Button", "$parent_Button"..i, Frame)
            Button:SetSize(Frame:GetWidth()-55, 16)
            Button:SetNormalFontObject(GameFontHighlightLeft)
            if i == 1 then
                Button:SetPoint("TOPLEFT", ScrollBar, 8, 0)
            else
                Button:SetPoint("TOPLEFT", Frame.Buttons[i-1], "BOTTOMLEFT")
            end
            Button:SetScript("OnClick", function(self) if(Frame.ButtonOnClick) then Frame:ButtonOnClick(i) end end)
            local MiscButton = CreateFrame("Button", "$parent_Button"..i.."_Misc", Frame)
            MiscButton:SetSize(16, 16)
            MiscButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Disabled")
            MiscButton:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
            MiscButton:SetHighlightTexture("Interface\\Buttons\\UI-MinusButton-Up")
            MiscButton:SetNormalFontObject(GameFontHighlightLeft)
            MiscButton:SetPoint("TOPLEFT", Button, "TOPRIGHT", 0, 0)
            MiscButton:SetScript("OnClick", function(self) if(Frame.MiscOnClick) then Frame:MiscOnClick(i) end end)
            Button.MiscButton = MiscButton
            rawset(t, i, Button)
            return Button
        end })

        Frame.Buttons = Buttons
        Frame:Update()

        -- Resize grip (bottom-right corner)
        Frame:SetResizable(true)
        Frame:SetMinResize(150, 80)
        local resizeGrip = CreateFrame("Button", name.."_ResizeGrip", Frame)
        resizeGrip:SetSize(16, 16)
        resizeGrip:SetPoint("BOTTOMRIGHT", Frame, "BOTTOMRIGHT", 0, 0)
        resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        resizeGrip:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then Frame:StartSizing("BOTTOMRIGHT") end
        end)
        resizeGrip:SetScript("OnMouseUp", function(self, button)
            Frame:StopMovingOrSizing()
            Frame:Update()
        end)
        Frame:SetScript("OnSizeChanged", function(self, w, h)
            self.ButtonCount = math.floor((h - 32) / 16)
            local i = 1
            while rawget(self.Buttons, i) do
                self.Buttons[i]:SetWidth(w - 55)
                i = i + 1
            end
            self:Update()
        end)
    end
    function Frame:Position(FramePoint, Parent, ParentPoint, Ox, Oy)
        Frame.Default = {FramePoint, Parent, ParentPoint, Ox, Oy}
        Frame:SetPoint(FramePoint, Parent, ParentPoint, Ox, Oy)
    end
    table.insert(GOMove.Frames, Frame)
    return Frame
end

function GOMove:CreateButton(Frame, name, width, height, Ox, Oy)
    local Button = CreateFrame("Button", Frame:GetName().."_"..name, Frame, "UIPanelButtonTemplate")
    Button:SetSize(width, height)
    Button:SetText(name)
    Button:SetPoint("TOP", Frame, "TOP", Ox, Oy-10)
    Button:SetScript("OnClick", function(self) if(self.OnClick) then self:OnClick(Frame) end end)
    return Button
end

function GOMove:CreateInput(Frame, name, width, height, Ox, Oy, letters, default)
    local Input = CreateFrame("EditBox", Frame:GetName().."_"..name, Frame, "InputBoxTemplate")
    Input:SetSize(width, height)
    Input:SetPoint("TOP", Frame, "TOP", Ox+2.5, Oy-10)
    Input:SetAutoFocus(false)
    Input:SetNumeric(true)
    Input:SetMaxLetters(letters)
    Input:SetScript("OnEnterPressed", function() Input:ClearFocus() end)
    Input:SetScript("OnEscapePressed", function() Input:ClearFocus() end)
    if(default) then
        Input:SetNumber(default)
    end
    table.insert(GOMove.Inputs, Input)
    return Input
end

local trinityID = {}
local TIDs = 0
local function TID(name, reqguid, onetime)
    trinityID[name] = {TIDs, reqguid, onetime}
    TIDs = TIDs+1
end

-- NEED to be in order (same as server-side CommandIDs enum)
TID("TEST"              ,   false   ,   true    )
TID("SELECTNEAR"        ,   false   ,   true    )
TID("DELETE"            ,   true    ,   true    )
TID("X"                 ,   true    ,   false   )
TID("Y"                 ,   true    ,   false   )
TID("Z"                 ,   true    ,   false   )
TID("O"                 ,   true    ,   false   )
TID("GROUND"            ,   true    ,   false   )
TID("FLOOR"             ,   true    ,   false   )
TID("RESPAWN"           ,   true    ,   true    )
TID("GOTO"              ,   true    ,   true    )
TID("FACE"              ,   false   ,   true    )

TID("SPAWN"             ,   false   ,   true    )
TID("NORTH"             ,   true    ,   false   )
TID("EAST"              ,   true    ,   false   )
TID("SOUTH"             ,   true    ,   false   )
TID("WEST"              ,   true    ,   false   )
TID("NORTHEAST"         ,   true    ,   false   )
TID("NORTHWEST"         ,   true    ,   false   )
TID("SOUTHEAST"         ,   true    ,   false   )
TID("SOUTHWEST"         ,   true    ,   false   )
TID("UP"                ,   true    ,   false   )
TID("DOWN"              ,   true    ,   false   )
TID("LEFT"              ,   true    ,   false   )
TID("RIGHT"             ,   true    ,   false   )
TID("PHASE"             ,   true    ,   false   )
TID("SCALE"             ,   true    ,   false   )
TID("SELECTALLNEAR"     ,   false   ,   true    )
TID("SPAWNSPELL"        ,   false   ,   true    )

function GOMove:Move(ID, input)
    if(UnitIsDeadOrGhost("player")) then
        NotWhileDeadError()
        return
    end
    for k, inputfield in ipairs(GOMove.Inputs) do
        inputfield:ClearFocus()
    end
    local ARG = 0
    if(input) then
        ARG = input
    end
    if(not trinityID[ID] or not tonumber(trinityID[ID][1])) then
        return
    end
    if(not trinityID[ID][2]) then
        SendChatMessage(".gomove "..trinityID[ID][1].." "..(0).." "..ARG)
    elseif(trinityID[ID][3] and tonumber(ARG) and tonumber(ARG) > 0) then
        SendChatMessage(".gomove "..trinityID[ID][1].." "..ARG.." "..(0))
    else
        local did = false
        for GUID, NAME in pairs(GOMove.Selected) do
            if(tonumber(GUID)) then
                SendChatMessage(".gomove "..trinityID[ID][1].." "..GUID.." "..ARG)
                if(ID == "GOTO") then
                    return
                end
                did = true
            end
        end
        if(not did) then
            UIErrorsFrame:AddMessage("No objects selected", 1.0, 0.0, 0.0, 53, 2)
            return
        end
    end
end
