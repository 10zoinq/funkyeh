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
    if _G.TitleText then _G.TitleText:Remove() end
    if _G.CloseBtnText then _G.CloseBtnText:Remove() end
    if _G.Panel1Bg then _G.Panel1Bg:Remove() end
    if _G.Panel1Title then _G.Panel1Title:Remove() end
    if _G.Panel2Bg then _G.Panel2Bg:Remove() end
    if _G.Panel2Title then _G.Panel2Title:Remove() end
    if _G.Panel3Bg then _G.Panel3Bg:Remove() end
    if _G.Panel3Title then _G.Panel3Title:Remove() end
    if _G.GenTglBg then _G.GenTglBg:Remove() end
    if _G.GenTglKnob then _G.GenTglKnob:Remove() end
    if _G.GenTglTxt then _G.GenTglTxt:Remove() end
    if _G.GenBoxTglBg then _G.GenBoxTglBg:Remove() end
    if _G.GenBoxTglKnob then _G.GenBoxTglKnob:Remove() end
    if _G.GenBoxTglTxt then _G.GenBoxTglTxt:Remove() end
    if _G.QualTglBg then _G.QualTglBg:Remove() end
    if _G.QualTglKnob then _G.QualTglKnob:Remove() end
    if _G.QualTglTxt then _G.QualTglTxt:Remove() end
    if _G.QualBoxTglBg then _G.QualBoxTglBg:Remove() end
    if _G.QualBoxTglKnob then _G.QualBoxTglKnob:Remove() end
    if _G.QualBoxTglTxt then _G.QualBoxTglTxt:Remove() end
    if _G.SliderBg then _G.SliderBg:Remove() end
    if _G.SliderFill then _G.SliderFill:Remove() end
    if _G.SliderKnob then _G.SliderKnob:Remove() end
    if _G.SliderText then _G.SliderText:Remove() end
    if _G.SliderValText then _G.SliderValText:Remove() end
    if _G.GenStatusText then _G.GenStatusText:Remove() end
    if _G.QualStatusText then _G.QualStatusText:Remove() end
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

-- Multi-ESP Pool Storage
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

-- Main Window Geometry
local winX, winY, winW, winH = 40, 80, 560, 370

-- Main Window Background Container
local mainBg = Drawing.new("Square")
mainBg.Visible = true
mainBg.Position = Vector2.new(winX, winY)
mainBg.Size = Vector2.new(winW, winH)
mainBg.Color = Color3.fromRGB(15, 15, 20)
mainBg.Filled = true
_G.MainBg = mainBg

-- Main Window Border Outline
local mainBorder = Drawing.new("Square")
mainBorder.Visible = true
mainBorder.Position = Vector2.new(winX - 1, winY - 1)
mainBorder.Size = Vector2.new(winW + 2, winH + 2)
mainBorder.Color = Color3.fromRGB(45, 45, 60)
mainBorder.Filled = false
_G.MainBorder = mainBorder

-- Title Text
local titleText = Drawing.new("Text")
titleText.Visible = true
titleText.Position = Vector2.new(winX + 16, winY + 12)
titleText.Size = 16
titleText.Color = Color3.fromRGB(240, 240, 250)
titleText.Outline = true
titleText.Text = "1984 Printer ESP & Automation"
_G.TitleText = titleText

-- Close [X] Button in Title Bar
local closeBtnText = Drawing.new("Text")
closeBtnText.Visible = true
closeBtnText.Position = Vector2.new(winX + winW - 32, winY + 12)
closeBtnText.Size = 16
closeBtnText.Color = Color3.fromRGB(255, 80, 80)
closeBtnText.Outline = true
closeBtnText.Text = "[X]"
_G.CloseBtnText = closeBtnText

-- ==================== PANEL 1: ESP (Top Left) ====================
local panel1Bg = Drawing.new("Square")
panel1Bg.Visible = true
panel1Bg.Color = Color3.fromRGB(22, 22, 30)
panel1Bg.Filled = true
_G.Panel1Bg = panel1Bg

local panel1Title = Drawing.new("Text")
panel1Title.Visible = true
panel1Title.Size = 14
panel1Title.Color = Color3.fromRGB(180, 180, 200)
panel1Title.Outline = true
panel1Title.Text = "ESP Settings"
_G.Panel1Title = panel1Title

-- ==================== PANEL 2: STATUS (Top Right) ====================
local panel2Bg = Drawing.new("Square")
panel2Bg.Visible = true
panel2Bg.Color = Color3.fromRGB(22, 22, 30)
panel2Bg.Filled = true
_G.Panel2Bg = panel2Bg

local panel2Title = Drawing.new("Text")
panel2Title.Visible = true
panel2Title.Size = 14
panel2Title.Color = Color3.fromRGB(180, 180, 200)
panel2Title.Outline = true
panel2Title.Text = "Status & Info"
_G.Panel2Title = panel2Title

-- ==================== PANEL 3: HIGHLIGHTING (Bottom Left) ====================
local panel3Bg = Drawing.new("Square")
panel3Bg.Visible = true
panel3Bg.Color = Color3.fromRGB(22, 22, 30)
panel3Bg.Filled = true
_G.Panel3Bg = panel3Bg

local panel3Title = Drawing.new("Text")
panel3Title.Visible = true
panel3Title.Size = 14
panel3Title.Color = Color3.fromRGB(180, 180, 200)
panel3Title.Outline = true
panel3Title.Text = "Highlighting"
_G.Panel3Title = panel3Title

-- Toggle Pill UI elements
local function createToggleElements()
    local bg = Drawing.new("Square")
    bg.Visible = true
    bg.Size = Vector2.new(36, 18)
    bg.Color = Color3.fromRGB(120, 90, 180)
    bg.Filled = true

    local knob = Drawing.new("Square")
    knob.Visible = true
    knob.Size = Vector2.new(14, 14)
    knob.Color = Color3.fromRGB(255, 255, 255)
    knob.Filled = true

    local txt = Drawing.new("Text")
    txt.Visible = true
    txt.Size = 13
    txt.Outline = true
    txt.Color = Color3.fromRGB(220, 220, 230)

    return bg, knob, txt
end

local genTglBg, genTglKnob, genTglTxt = createToggleElements()
local genBoxTglBg, genBoxTglKnob, genBoxTglTxt = createToggleElements()
local qualTglBg, qualTglKnob, qualTglTxt = createToggleElements()
local qualBoxTglBg, qualBoxTglKnob, qualBoxTglTxt = createToggleElements()

genTglTxt.Text = "Generic Printer ESP"
genBoxTglTxt.Text = "Generic Box Outline"
qualTglTxt.Text = "Quality Printer ESP"
qualBoxTglTxt.Text = "Quality Box Outline"

_G.GenTglBg = genTglBg; _G.GenTglKnob = genTglKnob; _G.GenTglTxt = genTglTxt
_G.GenBoxTglBg = genBoxTglBg; _G.GenBoxTglKnob = genBoxTglKnob; _G.GenBoxTglTxt = genBoxTglTxt
_G.QualTglBg = qualTglBg; _G.QualTglKnob = qualTglKnob; _G.QualTglTxt = qualTglTxt
_G.QualBoxTglBg = qualBoxTglBg; _G.QualBoxTglKnob = qualBoxTglKnob; _G.QualBoxTglTxt = qualBoxTglTxt

-- Slider Elements
local sliderBg = Drawing.new("Square")
sliderBg.Visible = true
sliderBg.Color = Color3.fromRGB(45, 45, 55)
sliderBg.Filled = true
_G.SliderBg = sliderBg

local sliderFill = Drawing.new("Square")
sliderFill.Visible = true
sliderFill.Color = Color3.fromRGB(120, 90, 180)
sliderFill.Filled = true
_G.SliderFill = sliderFill

local sliderKnob = Drawing.new("Square")
sliderKnob.Visible = true
sliderKnob.Size = Vector2.new(8, 16)
sliderKnob.Color = Color3.fromRGB(255, 255, 255)
sliderKnob.Filled = true
_G.SliderKnob = sliderKnob

local sliderText = Drawing.new("Text")
sliderText.Visible = true
sliderText.Size = 13
sliderText.Color = Color3.fromRGB(200, 200, 210)
sliderText.Outline = true
sliderText.Text = "Highlight render distance"
_G.SliderText = sliderText

local sliderValText = Drawing.new("Text")
sliderValText.Visible = true
sliderValText.Size = 13
sliderValText.Color = Color3.fromRGB(220, 220, 230)
sliderValText.Outline = true
sliderValText.Text = "500"
_G.SliderValText = sliderValText

-- Status labels inside Panel 2
local genStatusText = Drawing.new("Text")
genStatusText.Visible = true
genStatusText.Size = 13
genStatusText.Outline = true
genStatusText.Color = Color3.fromRGB(150, 150, 160)
genStatusText.Text = "Generic: [No Printers]"
_G.GenStatusText = genStatusText

local qualStatusText = Drawing.new("Text")
qualStatusText.Visible = true
qualStatusText.Size = 13
qualStatusText.Outline = true
qualStatusText.Color = Color3.fromRGB(150, 150, 160)
qualStatusText.Text = "Quality: [No Printers]"
_G.QualStatusText = qualStatusText

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
confTitle.Size = 18
confTitle.Color = Color3.fromRGB(255, 100, 100)
confTitle.Outline = true
confTitle.Text = "Close Script?"
_G.ConfTitle = confTitle

local confMsg = Drawing.new("Text")
confMsg.Visible = false
confMsg.Size = 15
confMsg.Color = Color3.fromRGB(230, 230, 240)
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
confYesText.Size = 15
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
confNoText.Size = 15
confNoText.Center = true
confNoText.Outline = true
confNoText.Color = Color3.fromRGB(255, 255, 255)
confNoText.Text = "No"
_G.ConfNoText = confNoText

-- Interaction States
local isDraggingWindow = false
local activeSlider = false
local windowOffset = Vector2.new(0, 0)
local wasMousePressed = false
local lastClick = 0
local lastKeyToggle = 0

-- Helper function to toggle main UI visibility state
local function setMainUIVisible(visible)
    mainBg.Visible = visible
    mainBorder.Visible = visible
    titleText.Visible = visible
    closeBtnText.Visible = visible
    panel1Bg.Visible = visible
    panel1Title.Visible = visible
    panel2Bg.Visible = visible
    panel2Title.Visible = visible
    panel3Bg.Visible = visible
    panel3Title.Visible = visible

    genTglBg.Visible = visible
    genTglKnob.Visible = visible
    genTglTxt.Visible = visible
    genBoxTglBg.Visible = visible
    genBoxTglKnob.Visible = visible
    genBoxTglTxt.Visible = visible

    qualTglBg.Visible = visible
    qualTglKnob.Visible = visible
    qualTglTxt.Visible = visible
    qualBoxTglBg.Visible = visible
    qualBoxTglKnob.Visible = visible
    qualBoxTglTxt.Visible = visible

    sliderBg.Visible = visible
    sliderFill.Visible = visible
    sliderKnob.Visible = visible
    sliderText.Visible = visible
    sliderValText.Visible = visible
    genStatusText.Visible = visible
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
        if _G.TitleText then _G.TitleText:Remove() end
        if _G.CloseBtnText then _G.CloseBtnText:Remove() end
        if _G.Panel1Bg then _G.Panel1Bg:Remove() end
        if _G.Panel1Title then _G.Panel1Title:Remove() end
        if _G.Panel2Bg then _G.Panel2Bg:Remove() end
        if _G.Panel2Title then _G.Panel2Title:Remove() end
        if _G.Panel3Bg then _G.Panel3Bg:Remove() end
        if _G.Panel3Title then _G.Panel3Title:Remove() end
        if _G.GenTglBg then _G.GenTglBg:Remove() end
        if _G.GenTglKnob then _G.GenTglKnob:Remove() end
        if _G.GenTglTxt then _G.GenTglTxt:Remove() end
        if _G.GenBoxTglBg then _G.GenBoxTglBg:Remove() end
        if _G.GenBoxTglKnob then _G.GenBoxTglKnob:Remove() end
        if _G.GenBoxTglTxt then _G.GenBoxTglTxt:Remove() end
        if _G.QualTglBg then _G.QualTglBg:Remove() end
        if _G.QualTglKnob then _G.QualTglKnob:Remove() end
        if _G.QualTglTxt then _G.QualTglTxt:Remove() end
        if _G.QualBoxTglBg then _G.QualBoxTglBg:Remove() end
        if _G.QualBoxTglKnob then _G.QualBoxTglKnob:Remove() end
        if _G.QualBoxTglTxt then _G.QualBoxTglTxt:Remove() end
        if _G.SliderBg then _G.SliderBg:Remove() end
        if _G.SliderFill then _G.SliderFill:Remove() end
        if _G.SliderKnob then _G.SliderKnob:Remove() end
        if _G.SliderText then _G.SliderText:Remove() end
        if _G.SliderValText then _G.SliderValText:Remove() end
        if _G.GenStatusText then _G.GenStatusText:Remove() end
        if _G.QualStatusText then _G.QualStatusText:Remove() end
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

-- Main UI Render, Dragging, and Clicking Loop
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
    local cW, cH = 320, 140
    local cX = (viewportSize.X / 2) - (cW / 2)
    local cY = (viewportSize.Y / 2) - (cH / 2)

    confBorder.Position = Vector2.new(cX - 1, cY - 1)
    confBorder.Size = Vector2.new(cW + 2, cH + 2)
    confBg.Position = Vector2.new(cX, cY)
    confBg.Size = Vector2.new(cW, cH)
    confTitle.Position = Vector2.new(cX + 20, cY + 16)
    confMsg.Position = Vector2.new(cX + 20, cY + 48)

    local btnY = cY + 85
    local btnW, btnH = 132, 38
    local yesX, yesY = cX + 20, btnY
    local noX, noY = cX + cW - btnW - 20, btnY

    confYesBg.Position = Vector2.new(yesX, yesY)
    confYesBg.Size = Vector2.new(btnW, btnH)
    -- Perfectly centered vertically inside the button box
    confYesText.Position = Vector2.new(yesX + (btnW / 2), yesY + (btnH / 2) - 9)

    confNoBg.Position = Vector2.new(noX, noY)
    confNoBg.Size = Vector2.new(btnW, btnH)
    -- Perfectly centered vertically inside the button box
    confNoText.Position = Vector2.new(noX + (btnW / 2), noY + (btnH / 2) - 9)

    if confirmingClose then
        setMainUIVisible(false)
        setConfModalVisible(true)

        if mousePressed and not wasMousePressed then
            local inYes = mouseX >= yesX and mouseX <= yesX + btnW and mouseY >= yesY and mouseY <= yesY + btnH
            local inNo = mouseX >= noX and mouseX <= noX + btnW and mouseY >= noY and mouseY <= noY + btnH
            
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

    local inCloseBtn = mouseX >= winX + winW - 32 and mouseX <= winX + winW - 8 and mouseY >= winY + 8 and mouseY <= winY + 28
    local inTitleBar = mouseX >= winX and mouseX <= winX + winW - 40 and mouseY >= winY and mouseY <= winY + 36

    -- Panel 1 (ESP Toggles)
    local p1X, p1Y, p1W, p1H = winX + 16, winY + 42, 250, 185
    panel1Bg.Position = Vector2.new(p1X, p1Y)
    panel1Bg.Size = Vector2.new(p1W, p1H)
    panel1Title.Position = Vector2.new(p1X + 14, p1Y + 12)

    -- Panel 2 (Status)
    local p2X, p2Y, p2W, p2H = winX + 278, winY + 42, 266, 185
    panel2Bg.Position = Vector2.new(p2X, p2Y)
    panel2Bg.Size = Vector2.new(p2W, p2H)
    panel2Title.Position = Vector2.new(p2X + 14, p2Y + 12)

    -- Panel 3 (Highlighting / Slider)
    local p3X, p3Y, p3W, p3H = winX + 16, winY + 235, 528, 120
    panel3Bg.Position = Vector2.new(p3X, p3Y)
    panel3Bg.Size = Vector2.new(p3W, p3H)
    panel3Title.Position = Vector2.new(p3X + 14, p3Y + 12)

    local tglX = p1X + p1W - 52
    local t1Y, t2Y, t3Y, t4Y = p1Y + 42, p1Y + 76, p1Y + 110, p1Y + 144

    genTglBg.Position = Vector2.new(tglX, t1Y)
    genTglTxt.Position = Vector2.new(p1X + 14, t1Y + 2)
    genBoxTglBg.Position = Vector2.new(tglX, t2Y)
    genBoxTglTxt.Position = Vector2.new(p1X + 14, t2Y + 2)
    qualTglBg.Position = Vector2.new(tglX, t3Y)
    qualTglTxt.Position = Vector2.new(p1X + 14, t3Y + 2)
    qualBoxTglBg.Position = Vector2.new(tglX, t4Y)
    qualBoxTglTxt.Position = Vector2.new(p1X + 14, t4Y + 2)

    genTglKnob.Position = Vector2.new(genEnabled and (tglX + 18) or (tglX + 2), t1Y + 2)
    genBoxTglKnob.Position = Vector2.new(genBoxEnabled and (tglX + 18) or (tglX + 2), t2Y + 2)
    qualTglKnob.Position = Vector2.new(qualEnabled and (tglX + 18) or (tglX + 2), t3Y + 2)
    qualBoxTglKnob.Position = Vector2.new(qualBoxEnabled and (tglX + 18) or (tglX + 2), t4Y + 2)

    genTglBg.Color = genEnabled and Color3.fromRGB(120, 90, 180) or Color3.fromRGB(50, 50, 65)
    genBoxTglBg.Color = genBoxEnabled and Color3.fromRGB(120, 90, 180) or Color3.fromRGB(50, 50, 65)
    qualTglBg.Color = qualEnabled and Color3.fromRGB(120, 90, 180) or Color3.fromRGB(50, 50, 65)
    qualBoxTglBg.Color = qualBoxEnabled and Color3.fromRGB(120, 90, 180) or Color3.fromRGB(50, 50, 65)

    genStatusText.Position = Vector2.new(p2X + 14, p2Y + 50)
    qualStatusText.Position = Vector2.new(p2X + 14, p2Y + 95)

    local sX, sY, sW = p3X + 16, p3Y + 68, p3W - 32
    sliderBg.Position = Vector2.new(sX, sY)
    sliderBg.Size = Vector2.new(sW, 6)
    sliderText.Position = Vector2.new(sX, sY - 24)
    sliderValText.Position = Vector2.new(sX + sW - 45, sY - 24)
    sliderValText.Text = tostring(genMaxDist)

    local sPercent = math.clamp((genMaxDist - 10) / 9990, 0, 1)
    local sFillW = math.clamp(sW * sPercent, 2, sW)
    sliderFill.Position = Vector2.new(sX, sY)
    sliderFill.Size = Vector2.new(sFillW, 6)
    sliderKnob.Position = Vector2.new(sX + sFillW - 4, sY - 5)

    local inGenTgl = mouseX >= tglX and mouseX <= tglX + 36 and mouseY >= t1Y and mouseY <= t1Y + 18
    local inGenBoxTgl = mouseX >= tglX and mouseX <= tglX + 36 and mouseY >= t2Y and mouseY <= t2Y + 18
    local inQualTgl = mouseX >= tglX and mouseX <= tglX + 36 and mouseY >= t3Y and mouseY <= t3Y + 18
    local inQualBoxTgl = mouseX >= tglX and mouseX <= tglX + 36 and mouseY >= t4Y and mouseY <= t4Y + 18
    local inSlider = mouseX >= sX - 10 and mouseX <= sX + sW + 10 and mouseY >= sY - 12 and mouseY <= sY + 20

    if mousePressed then
        if not wasMousePressed then
            if inCloseBtn then
                confirmingClose = true
                return
            elseif inTitleBar then
                isDraggingWindow = true
                windowOffset = Vector2.new(mouseX - winX, mouseY - winY)
            elseif inSlider then
                activeSlider = true
            end
        end

        if isDraggingWindow then
            winX = mouseX - windowOffset.X
            winY = mouseY - windowOffset.Y
        elseif activeSlider then
            local percent = math.clamp((mouseX - sX) / sW, 0, 1)
            genMaxDist = math.floor(10 + (percent * 9990))
            qualMaxDist = genMaxDist
        end
    else
        if wasMousePressed then
            if tick() - lastClick > 0.3 then
                if inGenTgl then
                    lastClick = tick()
                    genEnabled = not genEnabled
                elseif inGenBoxTgl then
                    lastClick = tick()
                    genBoxEnabled = not genBoxEnabled
                elseif inQualTgl  then
                    lastClick = tick()
                    qualEnabled = not qualEnabled
                elseif inQualBoxTgl then
                    lastClick = tick()
                    qualBoxEnabled = not qualBoxEnabled
                end
            end
        end

        isDraggingWindow = false
        activeSlider = false
    end

    wasMousePressed = mousePressed

    mainBg.Position = Vector2.new(winX, winY)
    mainBorder.Position = Vector2.new(winX - 1, winY - 1)
    titleText.Position = Vector2.new(winX + 16, winY + 12)
    closeBtnText.Position = Vector2.new(winX + winW - 32, winY + 12)
end)

-- Main ESP Render Loop
_G.PrinterESPConn = RunService.RenderStepped:Connect(function()
    for _, obj in ipairs(_G.ActiveESPDrawings) do
        obj.Visible = false
    end

    if not uiVisible or confirmingClose then
        genStatusText.Text = "Generic: [Hidden]"
        qualStatusText.Text = "Quality: [Hidden]"
        return
    end

    local cargoFolder = workspace:FindFirstChild("Cargo")
    local character = localPlayer and localPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not cargoFolder or not hrp then
        genStatusText.Text = "Generic: [No Cargo/HRP]"
        qualStatusText.Text = "Quality: [No Cargo/HRP]"
        return
    end

    local rootPos = hrp.Position
    local genFoundCount = 0
    local qualFoundCount = 0
    local genDrawingIndex = 1
    local qualDrawingIndex = 1

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

    if not genEnabled then
        genStatusText.Text = "Generic: [Disabled]"
        genStatusText.Color = Color3.fromRGB(200, 100, 100)
    elseif genFoundCount > 0 then
        genStatusText.Text = string.format("Generic: Found %d printer(s)", genFoundCount)
        genStatusText.Color = Color3.fromRGB(0, 255, 100)
    else
        genStatusText.Text = "Generic: [No Printers]"
        genStatusText.Color = Color3.fromRGB(150, 150, 160)
    end

    if not qualEnabled then
        qualStatusText.Text = "Quality: [Disabled]"
        qualStatusText.Color = Color3.fromRGB(200, 100, 100)
    elseif qualFoundCount > 0 then
        qualStatusText.Text = string.format("Quality: Found %d printer(s)", qualFoundCount)
        qualStatusText.Color = Color3.fromRGB(0, 255, 100)
    else
        qualStatusText.Text = "Quality: [No Printers]"
        qualStatusText.Color = Color3.fromRGB(150, 150, 160)
    end
end)
