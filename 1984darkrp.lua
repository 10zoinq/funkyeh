-- Safe cleanup of old drawings and connections if re-executed
pcall(function()
    if _G.PrinterESPConn then _G.PrinterESPConn:Disconnect() end
    if _G.PrinterClickConn then _G.PrinterClickConn:Disconnect() end
    if _G.ActiveESPDrawings then
        for _, obj in pairs(_G.ActiveESPDrawings) do
            pcall(function() obj:Remove() end)
        end
    end
    if _G.MainBorder then _G.MainBorder:Remove() end
    if _G.MainBg then _G.MainBg:Remove() end
    if _G.AccentBar then _G.AccentBar:Remove() end
    if _G.TitleText then _G.TitleText:Remove() end
    if _G.CloseBtnText then _G.CloseBtnText:Remove() end
    if _G.GenBoxBg then _G.GenBoxBg:Remove() end
    if _G.GenHeader then _G.GenHeader:Remove() end
    if _G.GenBtnBg then _G.GenBtnBg:Remove() end
    if _G.GenBtnText then _G.GenBtnText:Remove() end
    if _G.GenBoxBtnBg then _G.GenBoxBtnBg:Remove() end
    if _G.GenBoxBtnText then _G.GenBoxBtnText:Remove() end
    if _G.GenSliderBg then _G.GenSliderBg:Remove() end
    if _G.GenSliderFill then _G.GenSliderFill:Remove() end
    if _G.GenSliderKnob then _G.GenSliderKnob:Remove() end
    if _G.GenSliderText then _G.GenSliderText:Remove() end
    if _G.GenStatusText then _G.GenStatusText:Remove() end
    if _G.QualBoxBg then _G.QualBoxBg:Remove() end
    if _G.QualHeader then _G.QualHeader:Remove() end
    if _G.QualBtnBg then _G.QualBtnBg:Remove() end
    if _G.QualBtnText then _G.QualBtnText:Remove() end
    if _G.QualBoxBtnBg then _G.QualBoxBtnBg:Remove() end
    if _G.QualBoxBtnText then _G.QualBoxBtnText:Remove() end
    if _G.QualSliderBg then _G.QualSliderBg:Remove() end
    if _G.QualSliderFill then _G.QualSliderFill:Remove() end
    if _G.QualSliderKnob then _G.QualSliderKnob:Remove() end
    if _G.QualSliderText then _G.QualSliderText:Remove() end
    if _G.QualStatusText then _G.QualStatusText:Remove() end
    if _G.ResizeHandle then _G.ResizeHandle:Remove() end
    if _G.ConfBorder then _G.ConfBorder:Remove() end
    if _G.ConfBg then _G.ConfBg:Remove() end
    if _G.ConfTitle then _G.ConfTitle:Remove() end
    if _G.ConfMsg then _G.ConfMsg:Remove() end
    if _G.ConfYesBg then _G.ConfYesBg:Remove() end
    if _G.ConfYesText then _G.ConfYesText:Remove() end
    if _G.ConfNoBg then _G.ConfNoBg:Remove() end
    if _G.ConfNoText then _G.ConfNoText:Remove() end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- Settings state
local uiVisible = true
local confirmingClose = false

local genEnabled = true
local genBoxEnabled = true
local genMaxDist = 500

local qualEnabled = true
local qualBoxEnabled = true
local qualMaxDist = 500

-- Multi-ESP Pool Storage (Box, NameText, StatText)
_G.ActiveESPDrawings = {}
local function createESPTriplet(color)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = color
    box.Thickness = 2
    box.Filled = false
    table.insert(_G.ActiveESPDrawings, box)

    local txtName = Drawing.new("Text")
    txtName.Visible = false
    txtName.Color = color
    txtName.Size = 15
    txtName.Center = true
    txtName.Outline = true
    table.insert(_G.ActiveESPDrawings, txtName)

    local txtStats = Drawing.new("Text")
    txtStats.Visible = false
    txtStats.Color = Color3.fromRGB(220, 220, 230)
    txtStats.Size = 13
    txtStats.Center = true
    txtStats.Outline = true
    table.insert(_G.ActiveESPDrawings, txtStats)

    return box, txtName, txtStats
end

-- UI Window Geometry (Position: X: 30, Y: 100, Width: 235, Height: 355)
local winX, winY, winW, winH = 30, 100, 235, 355

-- Window Border
local mainBorder = Drawing.new("Square")
mainBorder.Visible = true
mainBorder.Position = Vector2.new(winX - 1, winY - 1)
mainBorder.Size = Vector2.new(winW + 2, winH + 2)
mainBorder.Color = Color3.fromRGB(45, 45, 55)
mainBorder.Filled = true
_G.MainBorder = mainBorder

-- Window Background
local mainBg = Drawing.new("Square")
mainBg.Visible = true
mainBg.Position = Vector2.new(winX, winY)
mainBg.Size = Vector2.new(winW, winH)
mainBg.Color = Color3.fromRGB(15, 15, 20)
mainBg.Filled = true
_G.MainBg = mainBg

-- Top Accent Line
local accentBar = Drawing.new("Square")
accentBar.Visible = true
accentBar.Position = Vector2.new(winX, winY)
accentBar.Size = Vector2.new(winW, 3)
accentBar.Color = Color3.fromRGB(0, 170, 255)
accentBar.Filled = true
_G.AccentBar = accentBar

-- Title Text
local titleText = Drawing.new("Text")
titleText.Visible = true
titleText.Position = Vector2.new(winX + 12, winY + 8)
titleText.Size = 16
titleText.Color = Color3.fromRGB(230, 230, 240)
titleText.Outline = true
titleText.Text = "1984 Printer ESP"
_G.TitleText = titleText

-- Close [X] Button in Title Bar
local closeBtnText = Drawing.new("Text")
closeBtnText.Visible = true
closeBtnText.Size = 16
closeBtnText.Color = Color3.fromRGB(255, 80, 80)
closeBtnText.Outline = true
closeBtnText.Text = "[X]"
_G.CloseBtnText = closeBtnText

-- Resize Handle Indicator (Bottom Right)
local resizeHandle = Drawing.new("Text")
resizeHandle.Visible = true
resizeHandle.Size = 13
resizeHandle.Color = Color3.fromRGB(100, 100, 120)
resizeHandle.Outline = true
resizeHandle.Text = "◢"
_G.ResizeHandle = resizeHandle

-- ==================== CONFIRMATION MODAL DRAWINGS ====================
local confBorder = Drawing.new("Square")
confBorder.Visible = false
confBorder.Color = Color3.fromRGB(70, 70, 85)
confBorder.Filled = true
_G.ConfBorder = confBorder

local confBg = Drawing.new("Square")
confBg.Visible = false
confBg.Color = Color3.fromRGB(18, 18, 25)
confBg.Filled = true
_G.ConfBg = confBg

local confTitle = Drawing.new("Text")
confTitle.Visible = false
confTitle.Size = 15
confTitle.Color = Color3.fromRGB(255, 100, 100)
confTitle.Outline = true
confTitle.Text = "Close Script?"
_G.ConfTitle = confTitle

local confMsg = Drawing.new("Text")
confMsg.Visible = false
confMsg.Size = 14
confMsg.Color = Color3.fromRGB(220, 220, 230)
confMsg.Outline = true
confMsg.Text = "Do you want to close the script?"
_G.ConfMsg = confMsg

local confYesBg = Drawing.new("Square")
confYesBg.Visible = false
confYesBg.Color = Color3.fromRGB(40, 130, 60)
confYesBg.Filled = true
_G.ConfYesBg = confYesBg

local confYesText = Drawing.new("Text")
confYesText.Visible = false
confYesText.Size = 14
confYesText.Center = true
confYesText.Outline = true
confYesText.Color = Color3.fromRGB(255, 255, 255)
confYesText.Text = "Yes"
_G.ConfYesText = confYesText

local confNoBg = Drawing.new("Square")
confNoBg.Visible = false
confNoBg.Color = Color3.fromRGB(150, 45, 45)
confNoBg.Filled = true
_G.ConfNoBg = confNoBg

local confNoText = Drawing.new("Text")
confNoText.Visible = false
confNoText.Size = 14
confNoText.Center = true
confNoText.Outline = true
confNoText.Color = Color3.fromRGB(255, 255, 255)
confNoText.Text = "No"
_G.ConfNoText = confNoText

-- ==================== SECTION 1: GENERIC PRINTERS ====================
local genBoxBg = Drawing.new("Square")
genBoxBg.Visible = true
genBoxBg.Color = Color3.fromRGB(22, 22, 30)
genBoxBg.Filled = true
_G.GenBoxBg = genBoxBg

local genHeader = Drawing.new("Text")
genHeader.Visible = true
genHeader.Size = 14
genHeader.Color = Color3.fromRGB(0, 170, 255)
genHeader.Outline = true
genHeader.Text = "Generic Printers"
_G.GenHeader = genHeader

local genBtnBg = Drawing.new("Square")
local genBtnText = Drawing.new("Text")
local genBoxBtnBg = Drawing.new("Square")
local genBoxBtnText = Drawing.new("Text")
local genSliderBg = Drawing.new("Square")
local genSliderFill = Drawing.new("Square")
local genSliderKnob = Drawing.new("Square")
local genSliderText = Drawing.new("Text")
local genStatusText = Drawing.new("Text")

-- ==================== SECTION 2: QUALITY PRINTERS ====================
local qualBoxBg = Drawing.new("Square")
qualBoxBg.Visible = true
qualBoxBg.Color = Color3.fromRGB(22, 22, 30)
qualBoxBg.Filled = true
_G.QualBoxBg = qualBoxBg

local qualHeader = Drawing.new("Text")
qualHeader.Visible = true
qualHeader.Size = 14
qualHeader.Color = Color3.fromRGB(255, 60, 60)
qualHeader.Outline = true
qualHeader.Text = "Quality Printers"
_G.QualHeader = qualHeader

local qualBtnBg = Drawing.new("Square")
local qualBtnText = Drawing.new("Text")
local qualBoxBtnBg = Drawing.new("Square")
local qualBoxBtnText = Drawing.new("Text")
local qualSliderBg = Drawing.new("Square")
local qualSliderFill = Drawing.new("Square")
local qualSliderKnob = Drawing.new("Square")
local qualSliderText = Drawing.new("Text")
local qualStatusText = Drawing.new("Text")

-- Initial properties
for _, txt in pairs({genBtnText, genBoxBtnText, qualBtnText, qualBoxBtnText}) do
    txt.Visible = true
    txt.Size = 13
    txt.Center = true
    txt.Outline = true
    txt.Color = Color3.fromRGB(0, 255, 100)
end
genBtnText.Text = "ESP: [ON]"
genBoxBtnText.Text = "Box ESP: [ON]"
qualBtnText.Text = "ESP: [ON]"
qualBoxBtnText.Text = "Box ESP: [ON]"

for _, obj in pairs({genBtnBg, genBoxBtnBg, qualBtnBg, qualBoxBtnBg}) do
    obj.Visible = true
    obj.Color = Color3.fromRGB(35, 35, 45)
    obj.Filled = true
end

for _, sBg in pairs({genSliderBg, qualSliderBg}) do
    sBg.Visible = true
    sBg.Size = Vector2.new(1, 5)
    sBg.Color = Color3.fromRGB(45, 45, 55)
    sBg.Filled = true
end

for _, sFill in pairs({genSliderFill, qualSliderFill}) do
    sFill.Visible = true
    sFill.Size = Vector2.new(1, 5)
    sFill.Color = Color3.fromRGB(0, 170, 255)
    sFill.Filled = true
end

for _, sKnob in pairs({genSliderKnob, qualSliderKnob}) do
    sKnob.Visible = true
    sKnob.Size = Vector2.new(7, 14)
    sKnob.Color = Color3.fromRGB(255, 255, 255)
    sKnob.Filled = true
end

for _, sTxt in pairs({genSliderText, qualSliderText}) do
    sTxt.Visible = true
    sTxt.Size = 13
    sTxt.Color = Color3.fromRGB(200, 200, 210)
    sTxt.Outline = true
end

for _, statTxt in pairs({genStatusText, qualStatusText}) do
    statTxt.Visible = true
    statTxt.Size = 13
    statTxt.Outline = true
    statTxt.Color = Color3.fromRGB(150, 150, 160)
    statTxt.Text = "Status: [No Printers]"
end

-- Interaction States
local isDraggingWindow = false
local isResizingWindow = false
local activeSlider = nil
local windowOffset = Vector2.new(0, 0)
local wasMousePressed = false
local lastClick = 0
local lastKeyToggle = 0

-- Helper function to toggle main UI visibility state
local function setMainUIVisible(visible)
    mainBorder.Visible = visible
    mainBg.Visible = visible
    accentBar.Visible = visible
    titleText.Visible = visible
    closeBtnText.Visible = visible
    resizeHandle.Visible = visible
    
    genBoxBg.Visible = visible
    genHeader.Visible = visible
    genBtnBg.Visible = visible
    genBtnText.Visible = visible
    genBoxBtnBg.Visible = visible
    genBoxBtnText.Visible = visible
    genSliderBg.Visible = visible
    genSliderFill.Visible = visible
    genSliderKnob.Visible = visible
    genSliderText.Visible = visible
    genStatusText.Visible = visible
    
    qualBoxBg.Visible = visible
    qualHeader.Visible = visible
    qualBtnBg.Visible = visible
    qualBtnText.Visible = visible
    qualBoxBtnBg.Visible = visible
    qualBoxBtnText.Visible = visible
    qualSliderBg.Visible = visible
    qualSliderFill.Visible = visible
    qualSliderKnob.Visible = visible
    qualSliderText.Visible = visible
    qualStatusText.Visible = visible

    if not visible then
        for _, obj in ipairs(_G.ActiveESPDrawings) do
            obj.Visible = false
        end
    end
end

-- Helper function to toggle confirmation modal visibility state
local function setConfModalVisible(visible)
    confBorder.Visible = visible
    confBg.Visible = visible
    confTitle.Visible = visible
    confMsg.Visible = visible
    confYesBg.Visible = visible
    confYesText.Visible = visible
    confNoBg.Visible = visible
    confNoText.Visible = visible
end

-- Function to completely wipe the script and close drawings
local function fullShutdown()
    pcall(function()
        if _G.PrinterESPConn then _G.PrinterESPConn:Disconnect() end
        if _G.PrinterClickConn then _G.PrinterClickConn:Disconnect() end
        if _G.ActiveESPDrawings then
            for _, obj in pairs(_G.ActiveESPDrawings) do
                pcall(function() obj:Remove() end)
            end
        end
        if _G.MainBorder then _G.MainBorder:Remove() end
        if _G.MainBg then _G.MainBg:Remove() end
        if _G.AccentBar then _G.AccentBar:Remove() end
        if _G.TitleText then _G.TitleText:Remove() end
        if _G.CloseBtnText then _G.CloseBtnText:Remove() end
        if _G.GenBoxBg then _G.GenBoxBg:Remove() end
        if _G.GenHeader then _G.GenHeader:Remove() end
        if _G.GenBtnBg then _G.GenBtnBg:Remove() end
        if _G.GenBtnText then _G.GenBtnText:Remove() end
        if _G.GenBoxBtnBg then _G.GenBoxBtnBg:Remove() end
        if _G.GenBoxBtnText then _G.GenBoxBtnText:Remove() end
        if _G.GenSliderBg then _G.GenSliderBg:Remove() end
        if _G.GenSliderFill then _G.GenSliderFill:Remove() end
        if _G.GenSliderKnob then _G.GenSliderKnob:Remove() end
        if _G.GenSliderText then _G.GenSliderText:Remove() end
        if _G.GenStatusText then _G.GenStatusText:Remove() end
        if _G.QualBoxBg then _G.QualBoxBg:Remove() end
        if _G.QualHeader then _G.QualHeader:Remove() end
        if _G.QualBtnBg then _G.QualBtnBg:Remove() end
        if _G.QualBtnText then _G.QualBtnText:Remove() end
        if _G.QualBoxBtnBg then _G.QualBoxBtnBg:Remove() end
        if _G.QualBoxBtnText then _G.QualBoxBtnText:Remove() end
        if _G.QualSliderBg then _G.QualSliderBg:Remove() end
        if _G.QualSliderFill then _G.QualSliderFill:Remove() end
        if _G.QualSliderKnob then _G.QualSliderKnob:Remove() end
        if _G.QualSliderText then _G.QualSliderText:Remove() end
        if _G.QualStatusText then _G.QualStatusText:Remove() end
        if _G.ResizeHandle then _G.ResizeHandle:Remove() end
        if _G.ConfBorder then _G.ConfBorder:Remove() end
        if _G.ConfBg then _G.ConfBg:Remove() end
        if _G.ConfTitle then _G.ConfTitle:Remove() end
        if _G.ConfMsg then _G.ConfMsg:Remove() end
        if _G.ConfYesBg then _G.ConfYesBg:Remove() end
        if _G.ConfYesText then _G.ConfYesText:Remove() end
        if _G.ConfNoBg then _G.ConfNoBg:Remove() end
        if _G.ConfNoText then _G.ConfNoText:Remove() end
    end)
end

-- Helper to extract current money and max/remaining generation potential
local function getPrinterStats(model)
    local currentMoney = "$0"
    local remainingGen = nil

    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") then
            local txt = desc.Text
            if txt then
                if string.find(txt, "%$") then
                    currentMoney = txt
                elseif string.lower(desc.Name):find("max") or string.lower(desc.Name):find("limit") or tonumber(txt) then
                    local num = tonumber(txt:match("%d+"))
                    if num and num > 50 then
                        remainingGen = txt
                    end
                end
            end
        end
    end
    
    return currentMoney, remainingGen
end

-- Main UI Render, Dragging, Resizing, and Clicking Loop
_G.PrinterClickConn = RunService.RenderStepped:Connect(function()
    if tick() - lastKeyToggle > 0.25 then
        local success, isPressed = pcall(function()
            return UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        end)
        if success and isPressed then
            lastKeyToggle = tick()
            if confirmingClose then
                confirmingClose = false
                setConfModalVisible(false)
                setMainUIVisible(true)
                uiVisible = true
            else
                uiVisible = not uiVisible
                setMainUIVisible(uiVisible)
            end
        end
    end

    local mouseX, mouseY = mouse.X, mouse.Y
    local mousePressed = ismouse1pressed()

    -- Confirmation Modal Layout Bounds (Centered on screen)
    local viewportSize = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
    local cW, cH = 240, 105
    local cX = (viewportSize.X / 2) - (cW / 2)
    local cY = (viewportSize.Y / 2) - (cH / 2)

    confBorder.Position = Vector2.new(cX - 1, cY - 1)
    confBorder.Size = Vector2.new(cW + 2, cH + 2)
    confBg.Position = Vector2.new(cX, cY)
    confBg.Size = Vector2.new(cW, cH)
    confTitle.Position = Vector2.new(cX + 14, cY + 10)
    confMsg.Position = Vector2.new(cX + 14, cY + 34)

    local yesX, yesY, yesW, yesH = cX + 14, cY + 64, 100, 28
    local noX, noY, noW, noH = cX + 126, cY + 64, 100, 28

    confYesBg.Position = Vector2.new(yesX, yesY)
    confYesBg.Size = Vector2.new(yesW, yesH)
    confYesText.Position = Vector2.new(yesX + (yesW / 2), yesY + 6)

    confNoBg.Position = Vector2.new(noX, noY)
    confNoBg.Size = Vector2.new(noW, noH)
    confNoText.Position = Vector2.new(noX + (noW / 2), noY + 6)

    if confirmingClose then
        setMainUIVisible(false)
        setConfModalVisible(true)

        if mousePressed and not wasMousePressed then
            local inYes = mouseX >= yesX and mouseX <= yesX + yesW and mouseY >= yesY and mouseY <= yesY + yesH
            local inNo = mouseX >= noX and mouseX <= noX + noW and mouseY >= noY and mouseY <= noY + noH
            
            if inYes then
                fullShutdown()
                return
            elseif inNo then
                confirmingClose = false
                setConfModalVisible(false)
                setMainUIVisible(true)
                uiVisible = true
            end
        end
        wasMousePressed = mousePressed
        return
    else
        setConfModalVisible(false)
    end

    if not uiVisible then 
        setMainUIVisible(false)
        return 
    else
        setMainUIVisible(true)
    end

    local innerW = winW - 20

    -- Layout Bounds relative to winX, winY
    local gBoxX, gBoxY, gBoxW, gBoxH = winX + 10, winY + 35, winW - 20, 138
    local gBtnX, gBtnY = winX + 15, winY + 63
    local gBoxBtnX, gBoxBtnY = winX + 15, winY + 91
    local gSliderX, gSliderY = winX + 15, winY + 135

    local qBoxX, qBoxY, qBoxW, qBoxH = winX + 10, winY + 180, winW - 20, 138
    local qBtnX, qBtnY = winX + 15, winY + 208
    local qBoxBtnX, qBoxBtnY = winX + 15, winY + 236
    local qSliderX, qSliderY = winX + 15, winY + 280

    -- Hitboxes
    local inCloseBtn = mouseX >= winX + winW - 30 and mouseX <= winX + winW - 8 and mouseY >= winY + 6 and mouseY <= winY + 26
    local inTitleBar = mouseX >= winX and mouseX <= winX + winW - 35 and mouseY >= winY and mouseY <= winY + 30
    local inResizeHandle = mouseX >= winX + winW - 16 and mouseX <= winX + winW and mouseY >= winY + winH - 16 and mouseY <= winY + winH

    local inGenBtn = mouseX >= gBtnX and mouseX <= gBtnX + innerW and mouseY >= gBtnY and mouseY <= gBtnY + 22
    local inGenBoxBtn = mouseX >= gBoxBtnX and mouseX <= gBoxBtnX + innerW and mouseY >= gBoxBtnY and mouseY <= gBoxBtnY + 22
    local inGenSlider = mouseX >= gSliderX - 5 and mouseX <= gSliderX + innerW + 5 and mouseY >= gSliderY - 10 and mouseY <= gSliderY + 20

    local inQualBtn = mouseX >= qBtnX and mouseX <= qBtnX + innerW and mouseY >= qBtnY and mouseY <= qBtnY + 22
    local inQualBoxBtn = mouseX >= qBoxBtnX and mouseX <= qBoxBtnX + innerW and mouseY >= qBoxBtnY and mouseY <= qBoxBtnY + 22
    local inQualSlider = mouseX >= qSliderX - 5 and mouseX <= qSliderX + innerW + 5 and mouseY >= qSliderY - 10 and mouseY <= qSliderY + 20

    if mousePressed then
        if not wasMousePressed then
            if inCloseBtn then
                confirmingClose = true
                return
            elseif inResizeHandle then
                isResizingWindow = true
            elseif inTitleBar then
                isDraggingWindow = true
                windowOffset = Vector2.new(mouseX - winX, mouseY - winY)
            elseif inGenSlider then
                activeSlider = "gen"
            elseif inQualSlider then
                activeSlider = "qual"
            end
        end

        if isResizingWindow then
            winW = math.clamp(mouseX - winX, 200, 420)
            winH = math.clamp(mouseY - winY, 320, 620)
        elseif isDraggingWindow then
            winX = mouseX - windowOffset.X
            winY = mouseY - windowOffset.Y
        elseif activeSlider == "gen" then
            local percent = math.clamp((mouseX - gSliderX) / innerW, 0, 1)
            genMaxDist = math.floor(10 + (percent * 9990))
        elseif activeSlider == "qual" then
            local percent = math.clamp((mouseX - qSliderX) / innerW, 0, 1)
            qualMaxDist = math.floor(10 + (percent * 9990))
        end
    else
        if wasMousePressed then
            if tick() - lastClick > 0.3 then
                if inGenBtn then
                    lastClick = tick()
                    genEnabled = not genEnabled
                    genBtnText.Color = genEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
                    genBtnText.Text = genEnabled and "ESP: [ON]" or "ESP: [OFF]"
                elseif inGenBoxBtn then
                    lastClick = tick()
                    genBoxEnabled = not genBoxEnabled
                    genBoxBtnText.Color = genBoxEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
                    genBoxBtnText.Text = genBoxEnabled and "Box ESP: [ON]" or "Box ESP: [OFF]"
                elseif inQualBtn then
                    lastClick = tick()
                    qualEnabled = not qualEnabled
                    qualBtnText.Color = qualEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
                    qualBtnText.Text = qualEnabled and "ESP: [ON]" or "ESP: [OFF]"
                elseif inQualBoxBtn then
                    lastClick = tick()
                    qualBoxEnabled = not qualBoxEnabled
                    qualBoxBtnText.Color = qualBoxEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
                    qualBoxBtnText.Text = qualBoxEnabled and "Box ESP: [ON]" or "Box ESP: [OFF]"
                end
            end
        end

        isDraggingWindow = false
        isResizingWindow = false
        activeSlider = nil
    end

    wasMousePressed = mousePressed

    -- Recalculate component dimensions & positions
    mainBorder.Position = Vector2.new(winX - 1, winY - 1)
    mainBorder.Size = Vector2.new(winW + 2, winH + 2)
    mainBg.Position = Vector2.new(winX, winY)
    mainBg.Size = Vector2.new(winW, winH)
    accentBar.Position = Vector2.new(winX, winY)
    accentBar.Size = Vector2.new(winW, 3)
    titleText.Position = Vector2.new(winX + 12, winY + 8)
    closeBtnText.Position = Vector2.new(winX + winW - 28, winY + 7)
    resizeHandle.Position = Vector2.new(winX + winW - 15, winY + winH - 17)

    -- Generic Elements Update
    genBoxBg.Position = Vector2.new(gBoxX, gBoxY)
    genBoxBg.Size = Vector2.new(gBoxW, gBoxH)
    genHeader.Position = Vector2.new(gBoxX + 10, gBoxY + 8)
    genBtnBg.Position = Vector2.new(gBtnX, gBtnY)
    genBtnBg.Size = Vector2.new(innerW, 22)
    genBtnText.Position = Vector2.new(gBtnX + (innerW / 2), gBtnY + 4)

    genBoxBtnBg.Position = Vector2.new(gBoxBtnX, gBoxBtnY)
    genBoxBtnBg.Size = Vector2.new(innerW, 22)
    genBoxBtnText.Position = Vector2.new(gBoxBtnX + (innerW / 2), gBoxBtnY + 4)

    genSliderBg.Position = Vector2.new(gSliderX, gSliderY)
    genSliderBg.Size = Vector2.new(innerW, 5)
    genSliderFill.Position = Vector2.new(gSliderX, gSliderY)

    local gPercent = math.clamp((genMaxDist - 10) / 9990, 0, 1)
    local gFillW = math.clamp(innerW * gPercent, 2, innerW)
    genSliderFill.Size = Vector2.new(gFillW, 5)
    genSliderKnob.Position = Vector2.new(gSliderX + gFillW - 3, gSliderY - 4)
    genSliderText.Position = Vector2.new(gSliderX, gSliderY - 17)
    genSliderText.Text = string.format("Max Distance: %d studs", genMaxDist)
    genStatusText.Position = Vector2.new(gSliderX, gSliderY + 9)

    -- Quality Elements Update
    qualBoxBg.Position = Vector2.new(qBoxX, qBoxY)
    qualBoxBg.Size = Vector2.new(qBoxW, qBoxH)
    qualHeader.Position = Vector2.new(qBoxX + 10, qBoxY + 8)
    qualBtnBg.Position = Vector2.new(qBtnX, qBtnY)
    qualBtnBg.Size = Vector2.new(innerW, 22)
    qualBtnText.Position = Vector2.new(qBtnX + (innerW / 2), qBtnY + 4)

    qualBoxBtnBg.Position = Vector2.new(qBoxBtnX, qBoxBtnY)
    qualBoxBtnBg.Size = Vector2.new(innerW, 22)
    qualBoxBtnText.Position = Vector2.new(qBoxBtnX + (innerW / 2), qBoxBtnY + 4)

    qualSliderBg.Position = Vector2.new(qSliderX, qSliderY)
    qualSliderBg.Size = Vector2.new(innerW, 5)
    qualSliderFill.Position = Vector2.new(qSliderX, qSliderY)

    local qPercent = math.clamp((qualMaxDist - 10) / 9990, 0, 1)
    local qFillW = math.clamp(innerW * qPercent, 2, innerW)
    qualSliderFill.Size = Vector2.new(qFillW, 5)
    qualSliderKnob.Position = Vector2.new(qSliderX + qFillW - 3, qSliderY - 4)
    qualSliderText.Position = Vector2.new(qSliderX, qSliderY - 17)
    qualSliderText.Text = string.format("Max Distance: %d studs", qualMaxDist)
    qualStatusText.Position = Vector2.new(qSliderX, qSliderY + 9)
end)

-- Main ESP Render Loop featuring multi-line tags (Name top, Stats bottom)
_G.PrinterESPConn = RunService.RenderStepped:Connect(function()
    for _, obj in ipairs(_G.ActiveESPDrawings) do
        obj.Visible = false
    end

    if not uiVisible or confirmingClose then
        genStatusText.Text = "Status: [Hidden]"
        qualStatusText.Text = "Status: [Hidden]"
        return
    end

    local cargoFolder = workspace:FindFirstChild("Cargo")
    local character = localPlayer and localPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not cargoFolder or not hrp then
        genStatusText.Text = "Status: [No Cargo/HRP]"
        qualStatusText.Text = "Status: [No Cargo/HRP]"
        return
    end

    local rootPos = hrp.Position
    local genFoundCount = 0
    local qualFoundCount = 0
    local genDrawingIndex = 1
    local qualDrawingIndex = 1

    -- Pre-create drawing triplets (Box, Name, Stats) up to 20 each
    while #_G.ActiveESPDrawings < 120 do
        createESPTriplet(Color3.fromRGB(0, 170, 255))
        createESPTriplet(Color3.fromRGB(255, 60, 60))
    end

    for _, model in ipairs(cargoFolder:GetChildren()) do
        if model:IsA("Model") then
            local nameLower = model.Name:lower()
            local targetPart = model:FindFirstChild("Center") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

            if targetPart and targetPart.Position then
                local success, dist = pcall(function()
                    return math.floor((rootPos - targetPart.Position).Magnitude)
                end)

                if success and dist then
                    local currentMoney, remainingGen = getPrinterStats(model)
                    local isQuality = string.find(nameLower, "quality") or model.Name == "Quality Printer" or model.Name == "Quality Money Printer"
                    
                    if isQuality and qualEnabled and dist <= qualMaxDist then
                        qualFoundCount = qualFoundCount + 1
                        local pos, onScreen = WorldToScreen(targetPart.Position)
                        if onScreen then
                            local tripletIdx = 60 + ((qualDrawingIndex - 1) * 3) + 1
                            local box = _G.ActiveESPDrawings[tripletIdx]
                            local txtName = _G.ActiveESPDrawings[tripletIdx + 1]
                            local txtStats = _G.ActiveESPDrawings[tripletIdx + 2]

                            if box and txtName and txtStats then
                                if qualBoxEnabled then
                                    box.Visible = true
                                    box.Color = Color3.fromRGB(255, 60, 60)
                                    box.Position = Vector2.new(pos.X - 25, pos.Y - 25)
                                    box.Size = Vector2.new(50, 50)
                                else
                                    box.Visible = false
                                end

                                txtName.Visible = true
                                txtName.Color = Color3.fromRGB(255, 60, 60)
                                txtName.Text = model.Name .. " [" .. dist .. "s]"
                                txtName.Position = Vector2.new(pos.X, pos.Y - 50)

                                txtStats.Visible = true
                                if remainingGen then
                                    txtStats.Text = string.format("Has: %s | Left: %s", currentMoney, remainingGen)
                                else
                                    txtStats.Text = string.format("Has: %s", currentMoney)
                                end
                                txtStats.Position = Vector2.new(pos.X, pos.Y - 33)

                                qualDrawingIndex = qualDrawingIndex + 1
                            end
                        end
                    elseif not isQuality and (string.find(nameLower, "printer") or string.find(nameLower, "money")) and genEnabled and dist <= genMaxDist then
                        genFoundCount = genFoundCount + 1
                        local pos, onScreen = WorldToScreen(targetPart.Position)
                        if onScreen then
                            local tripletIdx = ((genDrawingIndex - 1) * 3) + 1
                            local box = _G.ActiveESPDrawings[tripletIdx]
                            local txtName = _G.ActiveESPDrawings[tripletIdx + 1]
                            local txtStats = _G.ActiveESPDrawings[tripletIdx + 2]

                            if box and txtName and txtStats then
                                if genBoxEnabled then
                                    box.Visible = true
                                    box.Color = Color3.fromRGB(0, 170, 255)
                                    box.Position = Vector2.new(pos.X - 25, pos.Y - 25)
                                    box.Size = Vector2.new(50, 50)
                                else
                                    box.Visible = false
                                end

                                txtName.Visible = true
                                txtName.Color = Color3.fromRGB(0, 170, 255)
                                txtName.Text = model.Name .. " [" .. dist .. "s]"
                                txtName.Position = Vector2.new(pos.X, pos.Y - 50)

                                txtStats.Visible = true
                                if remainingGen then
                                    txtStats.Text = string.format("Has: %s | Left: %s", currentMoney, remainingGen)
                                else
                                    txtStats.Text = string.format("Has: %s", currentMoney)
                                end
                                txtStats.Position = Vector2.new(pos.X, pos.Y - 33)

                                genDrawingIndex = genDrawingIndex + 1
                            end
                        end
                    end
                end
            end
        end
    end

    -- Update status text labels on UI
    if not genEnabled then
        genStatusText.Text = "Status: [Disabled]"
        genStatusText.Color = Color3.fromRGB(200, 100, 100)
    elseif genFoundCount > 0 then
        genStatusText.Text = string.format("Status: Found %d printer(s)", genFoundCount)
        genStatusText.Color = Color3.fromRGB(0, 255, 100)
    else
        genStatusText.Text = "Status: [No Printers]"
        genStatusText.Color = Color3.fromRGB(150, 150, 160)
    end

    if not qualEnabled then
        qualStatusText.Text = "Status: [Disabled]"
        qualStatusText.Color = Color3.fromRGB(200, 100, 100)
    elseif qualFoundCount > 0 then
        qualStatusText.Text = string.format("Status: Found %d printer(s)", qualFoundCount)
        qualStatusText.Color = Color3.fromRGB(0, 255, 100)
    else
        qualStatusText.Text = "Status: [No Printers]"
        qualStatusText.Color = Color3.fromRGB(150, 150, 160)
    end
end)
