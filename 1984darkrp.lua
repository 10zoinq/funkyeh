-- Safe cleanup of old drawings and connections if re-executed
pcall(function()
    if _G.PrinterESPConn then _G.PrinterESPConn:Disconnect() end
    if _G.PrinterClickConn then _G.PrinterClickConn:Disconnect() end
    if _G.CargoChildAddedConn then _G.CargoChildAddedConn:Disconnect() end
    if _G.CargoChildRemovedConn then _G.CargoChildRemovedConn:Disconnect() end
    if _G.ActiveESPDrawings then
        for _, obj in pairs(_G.ActiveESPDrawings) do
            pcall(function() obj:Remove() end)
        end
    end
    if _G.MainBorder then _G.MainBorder:Remove() end
    if _G.MainBg then _G.MainBg:Remove() end
    if _G.TitleText then _G.TitleText:Remove() end
    if _G.CloseBtnText then _G.CloseBtnText:Remove() end
    if _G.ResizeHandle then _G.ResizeHandle:Remove() end
    if _G.Panel1Bg then _G.Panel1Bg:Remove() end
    if _G.Panel1Title then _G.Panel1Title:Remove() end
    if _G.Panel2Bg then _G.Panel2Bg:Remove() end
    if _G.Panel2Title then _G.Panel2Title:Remove() end
    if _G.GenTglBg then _G.GenTglBg:Remove() end
    if _G.GenTglTxt then _G.GenTglTxt:Remove() end
    if _G.GenBoxTglBg then _G.GenBoxTglBg:Remove() end
    if _G.GenBoxTglTxt then _G.GenBoxTglTxt:Remove() end
    if _G.QualTglBg then _G.QualTglBg:Remove() end
    if _G.QualTglTxt then _G.QualTglTxt:Remove() end
    if _G.QualBoxTglBg then _G.QualBoxTglBg:Remove() end
    if _G.QualBoxTglTxt then _G.QualBoxTglTxt:Remove() end
    if _G.SliderBg then _G.SliderBg:Remove() end
    if _G.SliderFill then _G.SliderFill:Remove() end
    if _G.SliderKnob then _G.SliderKnob:Remove() end
    if _G.SliderText then _G.SliderText:Remove() end
    if _G.GenStatusText then _G.GenStatusText:Remove() end
    if _G.SliderBg2 then _G.SliderBg2:Remove() end
    if _G.SliderFill2 then _G.SliderFill2:Remove() end
    if _G.SliderKnob2 then _G.SliderKnob2:Remove() end
    if _G.SliderText2 then _G.SliderText2:Remove() end
    if _G.QualStatusText then _G.QualStatusText:Remove() end
    if _G.ConfBg then _G.ConfBg:Remove() end
    if _G.ConfBorder then _G.ConfBorder:Remove() end
    if _G.ConfText then _G.ConfText:Remove() end
    if _G.ConfYesBg then _G.ConfYesBg:Remove() end
    if _G.ConfYesTxt then _G.ConfYesTxt:Remove() end
    if _G.ConfNoBg then _G.ConfNoBg:Remove() end
    if _G.ConfNoTxt then _G.ConfNoTxt:Remove() end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
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
local winX, winY, winW, winH = 40, 80, 320, 420

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
titleText.Text = "1984 Printer ESP"
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

-- Resize Grip Indicator
local resizeHandle = Drawing.new("Text")
resizeHandle.Visible = true
resizeHandle.Size = 14
resizeHandle.Color = Color3.fromRGB(120, 120, 140)
resizeHandle.Outline = true
resizeHandle.Text = "◢"
_G.ResizeHandle = resizeHandle

-- ==================== CONFIRMATION POPUP ELEMENTS ====================
local confBg = Drawing.new("Square")
confBg.Visible = false
confBg.Color = Color3.fromRGB(20, 20, 28)
confBg.Filled = true
_G.ConfBg = confBg

local confBorder = Drawing.new("Square")
confBorder.Visible = false
confBorder.Color = Color3.fromRGB(70, 70, 90)
confBorder.Filled = false
_G.ConfBorder = confBorder

local confText = Drawing.new("Text")
confText.Visible = false
confText.Size = 13
confText.Center = true
confText.Outline = true
confText.Color = Color3.fromRGB(240, 240, 250)
confText.Text = "Are you sure you want to close the Script?"
_G.ConfText = confText

local confYesBg = Drawing.new("Square")
confYesBg.Visible = false
confYesBg.Color = Color3.fromRGB(40, 120, 60)
confYesBg.Filled = true
_G.ConfYesBg = confYesBg

local confYesTxt = Drawing.new("Text")
confYesTxt.Visible = false
confYesTxt.Size = 13
confYesTxt.Center = true
confYesTxt.Outline = true
confYesTxt.Color = Color3.fromRGB(255, 255, 255)
confYesTxt.Text = "Yes"
_G.ConfYesTxt = confYesTxt

local confNoBg = Drawing.new("Square")
confNoBg.Visible = false
confNoBg.Color = Color3.fromRGB(140, 40, 40)
confNoBg.Filled = true
_G.ConfNoBg = confNoBg

local confNoTxt = Drawing.new("Text")
confNoTxt.Visible = false
confNoTxt.Size = 13
confNoTxt.Center = true
confNoTxt.Outline = true
confNoTxt.Color = Color3.fromRGB(255, 255, 255)
confNoTxt.Text = "No"
_G.ConfNoTxt = confNoTxt

-- ==================== PANELS (Quality Top, Generic Bottom) ====================
local panel1Bg = Drawing.new("Square") -- Quality Panel (Top)
panel1Bg.Visible = true
panel1Bg.Color = Color3.fromRGB(22, 22, 30)
panel1Bg.Filled = true
_G.Panel1Bg = panel1Bg

local panel1Title = Drawing.new("Text")
panel1Title.Visible = true
panel1Title.Size = 14
panel1Title.Color = Color3.fromRGB(255, 60, 60)
panel1Title.Outline = true
panel1Title.Text = "Quality Printers"
_G.Panel1Title = panel1Title

local panel2Bg = Drawing.new("Square") -- Generic Panel (Bottom)
panel2Bg.Visible = true
panel2Bg.Color = Color3.fromRGB(22, 22, 30)
panel2Bg.Filled = true
_G.Panel2Bg = panel2Bg

local panel2Title = Drawing.new("Text")
panel2Title.Visible = true
panel2Title.Size = 14
panel2Title.Color = Color3.fromRGB(0, 170, 255)
panel2Title.Outline = true
panel2Title.Text = "Generic Printers"
_G.Panel2Title = panel2Title

-- Toggle Button UI elements
local function createToggleBox()
    local bg = Drawing.new("Square")
    bg.Visible = true
    bg.Size = Vector2.new(288, 26)
    bg.Color = Color3.fromRGB(35, 35, 45)
    bg.Filled = true

    local txt = Drawing.new("Text")
    txt.Visible = true
    txt.Size = 13
    txt.Center = true
    txt.Outline = true
    txt.Color = Color3.fromRGB(0, 255, 100)

    return bg, txt
end

-- Top Panel (Quality) Toggles & Sliders
local qualTglBg, qualTglTxt = createToggleBox()
local qualBoxTglBg, qualBoxTglTxt = createToggleBox()
_G.QualTglBg = qualTglBg; _G.QualTglTxt = qualTglTxt
_G.QualBoxTglBg = qualBoxTglBg; _G.QualBoxTglTxt = qualBoxTglTxt

local sliderBg2 = Drawing.new("Square")
sliderBg2.Visible = true
sliderBg2.Color = Color3.fromRGB(45, 45, 55)
sliderBg2.Filled = true
_G.SliderBg2 = sliderBg2

local sliderFill2 = Drawing.new("Square")
sliderFill2.Visible = true
sliderFill2.Color = Color3.fromRGB(255, 60, 60)
sliderFill2.Filled = true
_G.SliderFill2 = sliderFill2

local sliderKnob2 = Drawing.new("Square")
sliderKnob2.Visible = true
sliderKnob2.Size = Vector2.new(8, 16)
sliderKnob2.Color = Color3.fromRGB(255, 255, 255)
sliderKnob2.Filled = true
_G.SliderKnob2 = sliderKnob2

local sliderText2 = Drawing.new("Text")
sliderText2.Visible = true
sliderText2.Size = 13
sliderText2.Color = Color3.fromRGB(200, 200, 210)
sliderText2.Outline = true
sliderText2.Text = "Max Distance: 500 studs"
_G.SliderText2 = sliderText2

local qualStatusText = Drawing.new("Text")
qualStatusText.Visible = true
qualStatusText.Size = 13
qualStatusText.Outline = true
qualStatusText.Color = Color3.fromRGB(0, 255, 100)
qualStatusText.Text = "Status: [No Printers]"
_G.QualStatusText = qualStatusText

-- Bottom Panel (Generic) Toggles & Sliders
local genTglBg, genTglTxt = createToggleBox()
local genBoxTglBg, genBoxTglTxt = createToggleBox()
_G.GenTglBg = genTglBg; _G.GenTglTxt = genTglTxt
_G.GenBoxTglBg = genBoxTglBg; _G.GenBoxTglTxt = genBoxTglTxt

local sliderBg = Drawing.new("Square")
sliderBg.Visible = true
sliderBg.Color = Color3.fromRGB(45, 45, 55)
sliderBg.Filled = true
_G.SliderBg = sliderBg

local sliderFill = Drawing.new("Square")
sliderFill.Visible = true
sliderFill.Color = Color3.fromRGB(0, 170, 255)
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
sliderText.Text = "Max Distance: 500 studs"
_G.SliderText = sliderText

local genStatusText = Drawing.new("Text")
genStatusText.Visible = true
genStatusText.Size = 13
genStatusText.Outline = true
genStatusText.Color = Color3.fromRGB(0, 255, 100)
genStatusText.Text = "Status: [No Printers]"
_G.GenStatusText = genStatusText

-- Interaction States
local isDraggingWindow = false
local isResizingWindow = false
local activeSlider = false
local activeSlider2 = false
local windowOffset = Vector2.new(0, 0)
local resizeStartPos = Vector2.new(0, 0)
local resizeStartSize = Vector2.new(0, 0)
local wasMousePressed = false
local lastClick = 0
local lastKeyToggle = 0

-- Helper function to control main UI visibility state
local function setMainUIVisible(visible)
    mainBg.Visible = visible
    mainBorder.Visible = visible
    titleText.Visible = visible
    closeBtnText.Visible = visible
    resizeHandle.Visible = visible
    panel1Bg.Visible = visible
    panel1Title.Visible = visible
    panel2Bg.Visible = visible
    panel2Title.Visible = visible

    qualTglBg.Visible = visible
    qualTglTxt.Visible = visible
    qualBoxTglBg.Visible = visible
    qualBoxTglTxt.Visible = visible

    genTglBg.Visible = visible
    genTglTxt.Visible = visible
    genBoxTglBg.Visible = visible
    genBoxTglTxt.Visible = visible

    sliderBg2.Visible = visible
    sliderFill2.Visible = visible
    sliderKnob2.Visible = visible
    sliderText2.Visible = visible
    qualStatusText.Visible = visible

    sliderBg.Visible = visible
    sliderFill.Visible = visible
    sliderKnob.Visible = visible
    sliderText.Visible = visible
    genStatusText.Visible = visible

    if not visible then
        for _, obj in ipairs(_G.ActiveESPDrawings) do
            obj.Visible = false
        end
    end
end

-- Fully Cached Printer Management with strict filtering (ignores ComponentCrates)
local cachedPrinters = {}

local function updatePrinterCache()
    table.clear(cachedPrinters)
    local cargoFolder = workspace:FindFirstChild("Cargo")
    if not cargoFolder then return end

    for _, model in ipairs(cargoFolder:GetChildren()) do
        if model:IsA("Model") then
            local nameLower = model.Name:lower()
            if string.find(nameLower, "printer") and not string.find(nameLower, "crate") then
                local targetPart = model:FindFirstChild("Center") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
                if targetPart then
                    local isQuality = string.find(nameLower, "quality")
                    
                    table.insert(cachedPrinters, {
                        Model = model,
                        Part = targetPart,
                        IsQuality = isQuality,
                        CurrentMoney = "$0",
                        RemainingGen = nil,
                        LastStatUpdate = 0
                    })
                end
            end
        end
    end
end

-- Safely hook up folder events
task.spawn(function()
    local cargoFolder = workspace:FindFirstChild("Cargo")
    while not cargoFolder do
        cargoFolder = workspace:FindFirstChild("Cargo")
        if not cargoFolder then task.wait(1) end
    end
    
    if cargoFolder then
        _G.CargoChildAddedConn = cargoFolder.ChildAdded:Connect(updatePrinterCache)
        _G.CargoChildRemovedConn = cargoFolder.ChildRemoved:Connect(updatePrinterCache)
        updatePrinterCache()
    end
end)

-- Throttled Stat Reader
local function getPrinterStats(entry, now)
    if now - entry.LastStatUpdate < 0.6 then
        return entry.CurrentMoney, entry.RemainingGen
    end
    entry.LastStatUpdate = now

    local currentMoney = "$0"
    local remainingGen = nil

    pcall(function()
        for _, desc in ipairs(entry.Model:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                local txt = desc.Text
                if txt then
                    if string.find(txt, "%$") then
                        currentMoney = txt
                    elseif tonumber(txt) and tonumber(txt) > 50 then
                        remainingGen = txt
                    end
                end
            end
        end
    end)
    
    entry.CurrentMoney = currentMoney
    entry.RemainingGen = remainingGen
    return currentMoney, remainingGen
end

-- Full Cleanup function
local function fullUnload()
    pcall(function()
        if _G.PrinterESPConn then _G.PrinterESPConn:Disconnect() end
        if _G.PrinterClickConn then _G.PrinterClickConn:Disconnect() end
        if _G.CargoChildAddedConn then _G.CargoChildAddedConn:Disconnect() end
        if _G.CargoChildRemovedConn then _G.CargoChildRemovedConn:Disconnect() end
        if _G.ActiveESPDrawings then
            for _, obj in pairs(_G.ActiveESPDrawings) do
                pcall(function() obj:Remove() end)
            end
        end
        if _G.MainBorder then _G.MainBorder:Remove() end
        if _G.MainBg then _G.MainBg:Remove() end
        if _G.TitleText then _G.TitleText:Remove() end
        if _G.CloseBtnText then _G.CloseBtnText:Remove() end
        if _G.ResizeHandle then _G.ResizeHandle:Remove() end
        if _G.Panel1Bg then _G.Panel1Bg:Remove() end
        if _G.Panel1Title then _G.Panel1Title:Remove() end
        if _G.Panel2Bg then _G.Panel2Bg:Remove() end
        if _G.Panel2Title then _G.Panel2Title:Remove() end
        if _G.GenTglBg then _G.GenTglBg:Remove() end
        if _G.GenTglTxt then _G.GenTglTxt:Remove() end
        if _G.GenBoxTglBg then _G.GenBoxTglBg:Remove() end
        if _G.GenBoxTglTxt then _G.GenBoxTglTxt:Remove() end
        if _G.QualTglBg then _G.QualTglBg:Remove() end
        if _G.QualTglTxt then _G.QualTglTxt:Remove() end
        if _G.QualBoxTglBg then _G.QualBoxTglBg:Remove() end
        if _G.QualBoxTglTxt then _G.QualBoxTglTxt:Remove() end
        if _G.SliderBg then _G.SliderBg:Remove() end
        if _G.SliderFill then _G.SliderFill:Remove() end
        if _G.SliderKnob then _G.SliderKnob:Remove() end
        if _G.SliderText then _G.SliderText:Remove() end
        if _G.GenStatusText then _G.GenStatusText:Remove() end
        if _G.SliderBg2 then _G.SliderBg2:Remove() end
        if _G.SliderFill2 then _G.SliderFill2:Remove() end
        if _G.SliderKnob2 then _G.SliderKnob2:Remove() end
        if _G.SliderText2 then _G.SliderText2:Remove() end
        if _G.QualStatusText then _G.QualStatusText:Remove() end
        if _G.ConfBg then _G.ConfBg:Remove() end
        if _G.ConfBorder then _G.ConfBorder:Remove() end
        if _G.ConfText then _G.ConfText:Remove() end
        if _G.ConfYesBg then _G.ConfYesBg:Remove() end
        if _G.ConfYesTxt then _G.ConfYesTxt:Remove() end
        if _G.ConfNoBg then _G.ConfNoBg:Remove() end
        if _G.ConfNoTxt then _G.ConfNoTxt:Remove() end
    end)
end

-- Main UI Render, Dragging, Resizing, Confirmation and Clicking Loop
_G.PrinterClickConn = RunService.RenderStepped:Connect(function()
    if tick() - lastKeyToggle > 0.25 then
        local success, isPressed = pcall(function()
            return UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        end)
        if success and isPressed then
            lastKeyToggle = tick()
            if not confirmingClose then
                uiVisible = not uiVisible
            end
        end
    end

    if not uiVisible and not confirmingClose then 
        setMainUIVisible(false)
        confBg.Visible = false
        confBorder.Visible = false
        confText.Visible = false
        confYesBg.Visible = false
        confYesTxt.Visible = false
        confNoBg.Visible = false
        confNoTxt.Visible = false
        return 
    elseif not confirmingClose then
        setMainUIVisible(true)
    else
        setMainUIVisible(false)
    end

    local mouseX, mouseY = mouse.X, mouse.Y
    local mousePressed = ismouse1pressed()

    local inCloseBtn = mouseX >= winX + winW - 36 and mouseX <= winX + winW - 4 and mouseY >= winY + 6 and mouseY <= winY + 30
    local inTitleBar = mouseX >= winX and mouseX <= winX + winW - 40 and mouseY >= winY and mouseY <= winY + 36
    local inResizeHandle = mouseX >= winX + winW - 24 and mouseX <= winX + winW and mouseY >= winY + winH - 24 and mouseY <= winY + winH

    -- STRICT SIZE BARRIER (Locks window sizing inside clean readable limits)
    winW = math.clamp(winW, 300, 500)
    winH = math.clamp(winH, 400, 550)

    -- Panel Geometry inside Window
    local innerW = winW - 24
    local halfPanelH = math.floor((winH - 58) / 2) - 8

    -- Panel 1 Bounds (Quality Printers - TOP)
    local p1X, p1Y, p1W, p1H = winX + 12, winY + 42, innerW, halfPanelH
    panel1Bg.Position = Vector2.new(p1X, p1Y)
    panel1Bg.Size = Vector2.new(p1W, p1H)
    panel1Title.Position = Vector2.new(p1X + 12, p1Y + 10)

    -- Panel 2 Bounds (Generic Printers - BOTTOM)
    local p2X, p2Y, p2W, p2H = winX + 12, p1Y + p1H + 8, innerW, halfPanelH
    panel2Bg.Position = Vector2.new(p2X, p2Y)
    panel2Bg.Size = Vector2.new(p2W, p2H)
    panel2Title.Position = Vector2.new(p2X + 12, p2Y + 10)

    -- Quality Panel Elements Layout (TOP)
    qualTglBg.Size = Vector2.new(p1W - 8, 26)
    qualTglBg.Position = Vector2.new(p1X + 4, p1Y + 34)
    qualTglTxt.Position = Vector2.new(p1X + (p1W / 2), p1Y + 40)
    qualTglTxt.Text = "ESP: " .. (qualEnabled and "[ON]" or "[OFF]")
    qualTglTxt.Color = qualEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 80, 80)

    qualBoxTglBg.Size = Vector2.new(p1W - 8, 26)
    qualBoxTglBg.Position = Vector2.new(p1X + 4, p1Y + 66)
    qualBoxTglTxt.Position = Vector2.new(p1X + (p1W / 2), p1Y + 72)
    qualBoxTglTxt.Text = "Box ESP: " .. (qualBoxEnabled and "[ON]" or "[OFF]")
    qualBoxTglTxt.Color = qualBoxEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 80, 80)

    sliderText2.Position = Vector2.new(p1X + 12, p1Y + 100)
    sliderText2.Text = "Max Distance: " .. qualMaxDist .. " studs"
    
    local sX2, sY2, sW2 = p1X + 12, p1Y + 122, p1W - 24
    sliderBg2.Position = Vector2.new(sX2, sY2)
    sliderBg2.Size = Vector2.new(sW2, 6)
    
    local sPercent2 = math.clamp((qualMaxDist - 50) / 1450, 0, 1)
    local sFillW2 = math.clamp(sW2 * sPercent2, 2, sW2)
    sliderFill2.Position = Vector2.new(sX2, sY2)
    sliderFill2.Size = Vector2.new(sFillW2, 6)
    sliderKnob2.Position = Vector2.new(sX2 + sFillW2 - 4, sY2 - 5)

    qualStatusText.Position = Vector2.new(p1X + 12, p1Y + 140)

    -- Generic Panel Elements Layout (BOTTOM)
    genTglBg.Size = Vector2.new(p2W - 8, 26)
    genTglBg.Position = Vector2.new(p2X + 4, p2Y + 34)
    genTglTxt.Position = Vector2.new(p2X + (p2W / 2), p2Y + 40)
    genTglTxt.Text = "ESP: " .. (genEnabled and "[ON]" or "[OFF]")
    genTglTxt.Color = genEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 80, 80)

    genBoxTglBg.Size = Vector2.new(p2W - 8, 26)
    genBoxTglBg.Position = Vector2.new(p2X + 4, p2Y + 66)
    genBoxTglTxt.Position = Vector2.new(p2X + (p2W / 2), p2Y + 72)
    genBoxTglTxt.Text = "Box ESP: " .. (genBoxEnabled and "[ON]" or "[OFF]")
    genBoxTglTxt.Color = genBoxEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(200, 80, 80)

    sliderText.Position = Vector2.new(p2X + 12, p2Y + 100)
    sliderText.Text = "Max Distance: " .. genMaxDist .. " studs"
    
    local sX, sY, sW = p2X + 12, p2Y + 122, p2W - 24
    sliderBg.Position = Vector2.new(sX, sY)
    sliderBg.Size = Vector2.new(sW, 6)
    
    local sPercent = math.clamp((genMaxDist - 50) / 1450, 0, 1)
    local sFillW = math.clamp(sW * sPercent, 2, sW)
    sliderFill.Position = Vector2.new(sX, sY)
    sliderFill.Size = Vector2.new(sFillW, 6)
    sliderKnob.Position = Vector2.new(sX + sFillW - 4, sY - 5)

    genStatusText.Position = Vector2.new(p2X + 12, p2Y + 140)

    -- Confirmation Popup Geometry centered on screen viewport
    local viewportSize = Camera.ViewportSize
    local cW, cH = 320, 130
    local cX = math.floor((viewportSize.X - cW) / 2)
    local cY = math.floor((viewportSize.Y - cH) / 2)

    confBg.Position = Vector2.new(cX, cY)
    confBg.Size = Vector2.new(cW, cH)
    confBorder.Position = Vector2.new(cX - 1, cY - 1)
    confBorder.Size = Vector2.new(cW + 2, cH + 2)
    confText.Position = Vector2.new(cX + math.floor(cW / 2), cY + 22)

    local btnW, btnH = 110, 32
    local btnY = cY + 72
    local yesX = cX + 28
    local noX = cX + cW - btnW - 28

    confYesBg.Position = Vector2.new(yesX, btnY)
    confYesBg.Size = Vector2.new(btnW, btnH)
    confYesTxt.Position = Vector2.new(yesX + math.floor(btnW / 2), btnY + 8)

    confNoBg.Position = Vector2.new(noX, btnY)
    confNoBg.Size = Vector2.new(btnW, btnH)
    confNoTxt.Position = Vector2.new(noX + math.floor(btnW / 2), btnY + 8)

    confBg.Visible = confirmingClose
    confBorder.Visible = confirmingClose
    confText.Visible = confirmingClose
    confYesBg.Visible = confirmingClose
    confYesTxt.Visible = confirmingClose
    confNoBg.Visible = confirmingClose
    confNoTxt.Visible = confirmingClose

    -- Hitbox checks (Quality Top, Generic Bottom)
    local inQualTgl = not confirmingClose and mouseX >= p1X + 4 and mouseX <= p1X + p1W - 4 and mouseY >= p1Y + 34 and mouseY <= p1Y + 60
    local inQualBoxTgl = not confirmingClose and mouseX >= p1X + 4 and mouseX <= p1X + p1W - 4 and mouseY >= p1Y + 66 and mouseY <= p1Y + 92
    local inSlider2 = not confirmingClose and mouseX >= sX2 - 10 and mouseX <= sX2 + sW2 + 10 and mouseY >= sY2 - 12 and mouseY <= sY2 + 20

    local inGenTgl = not confirmingClose and mouseX >= p2X + 4 and mouseX <= p2X + p2W - 4 and mouseY >= p2Y + 34 and mouseY <= p2Y + 60
    local inGenBoxTgl = not confirmingClose and mouseX >= p2X + 4 and mouseX <= p2X + p2W - 4 and mouseY >= p2Y + 66 and mouseY <= p2Y + 92
    local inSlider = not confirmingClose and mouseX >= sX - 10 and mouseX <= sX + sW + 10 and mouseY >= sY - 12 and mouseY <= sY + 20

    local inYes = confirmingClose and mouseX >= yesX and mouseX <= yesX + btnW and mouseY >= btnY and mouseY <= btnY + btnH
    local inNo = confirmingClose and mouseX >= noX and mouseX <= noX + btnW and mouseY >= btnY and mouseY <= btnY + btnH

    if mousePressed then
        if not wasMousePressed then
            if confirmingClose then
                if inYes then
                    fullUnload()
                    return
                elseif inNo then
                    confirmingClose = false
                end
            else
                if inCloseBtn then
                    confirmingClose = true
                elseif inResizeHandle then
                    isResizingWindow = true
                    resizeStartPos = Vector2.new(mouseX, mouseY)
                    resizeStartSize = Vector2.new(winW, winH)
                elseif inTitleBar then
                    isDraggingWindow = true
                    windowOffset = Vector2.new(mouseX - winX, mouseY - winY)
                elseif inSlider then
                    activeSlider = true
                elseif inSlider2 then
                    activeSlider2 = true
                end
            end
        end

        if not confirmingClose then
            if isDraggingWindow then
                winX = mouseX - windowOffset.X
                winY = mouseY - windowOffset.Y
            elseif isResizingWindow then
                winW = math.clamp(resizeStartSize.X + (mouseX - resizeStartPos.X), 300, 500)
                winH = math.clamp(resizeStartSize.Y + (mouseY - resizeStartPos.Y), 400, 550)
            elseif activeSlider then
                local percent = math.clamp((mouseX - sX) / sW, 0, 1)
                genMaxDist = math.floor(50 + (percent * 1450))
            elseif activeSlider2 then
                local percent = math.clamp((mouseX - sX2) / sW2, 0, 1)
                qualMaxDist = math.floor(50 + (percent * 1450))
            end
        end
    else
        if wasMousePressed and not confirmingClose then
            if tick() - lastClick > 0.25 then
                if inQualTgl then
                    lastClick = tick()
                    qualEnabled = not qualEnabled
                elseif inQualBoxTgl then
                    lastClick = tick()
                    qualBoxEnabled = not qualBoxEnabled
                elseif inGenTgl then
                    lastClick = tick()
                    genEnabled = not genEnabled
                elseif inGenBoxTgl then
                    lastClick = tick()
                    genBoxEnabled = not genBoxEnabled
                end
            end
        end

        isDraggingWindow = false
        isResizingWindow = false
        activeSlider = false
        activeSlider2 = false
    end

    wasMousePressed = mousePressed

    -- Update window background container positions and dimensions
    mainBg.Position = Vector2.new(winX, winY)
    mainBg.Size = Vector2.new(winW, winH)
    mainBorder.Position = Vector2.new(winX - 1, winY - 1)
    mainBorder.Size = Vector2.new(winW + 2, winH + 2)
    titleText.Position = Vector2.new(winX + 16, winY + 12)
    closeBtnText.Position = Vector2.new(winX + winW - 32, winY + 12)
    resizeHandle.Position = Vector2.new(winX + winW - 16, winY + winH - 18)
end)

-- Main ESP Render Loop
local function getOrCreateESPObject(index)
    if not _G.ActiveESPDrawings[index] then
        local box = Drawing.new("Square")
        box.Visible = false
        box.Thickness = 2
        box.Filled = false

        local txtName = Drawing.new("Text")
        txtName.Visible = false
        txtName.Size = 15
        txtName.Center = true
        txtName.Outline = true

        local txtStats = Drawing.new("Text")
        txtStats.Visible = false
        txtStats.Color = Color3.fromRGB(220, 220, 230)
        txtStats.Size = 13
        txtStats.Center = true
        txtStats.Outline = true

        _G.ActiveESPDrawings[index] = { Box = box, Name = txtName, Stats = txtStats }
    end
    return _G.ActiveESPDrawings[index]
end

_G.PrinterESPConn = RunService.RenderStepped:Connect(function()
    for _, entry in pairs(_G.ActiveESPDrawings) do
        entry.Box.Visible = false
        entry.Name.Visible = false
        entry.Stats.Visible = false
    end

    if not uiVisible or confirmingClose then return end

    if #cachedPrinters == 0 then
        updatePrinterCache()
    end

    local character = localPlayer and localPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if not hrp then return end

    local rootPos = hrp.Position
    local genFoundCount = 0
    local qualFoundCount = 0
    local drawingIndex = 1
    local now = tick()

    for _, entry in ipairs(cachedPrinters) do
        if entry and entry.Model and entry.Part and entry.Part.Parent then
            local model = entry.Model
            local targetPart = entry.Part
            local dist = math.floor((rootPos - targetPart.Position).Magnitude)

            local pos2D, onScreen = WorldToScreen(targetPart.Position)

            if entry.IsQuality and qualEnabled and dist <= qualMaxDist then
                qualFoundCount = qualFoundCount + 1
                if onScreen then
                    local esp = getOrCreateESPObject(drawingIndex)
                    
                    if qualBoxEnabled then
                        esp.Box.Visible = true
                        esp.Box.Color = Color3.fromRGB(255, 60, 60)
                        esp.Box.Position = Vector2.new(pos2D.X - 25, pos2D.Y - 25)
                        esp.Box.Size = Vector2.new(50, 50)
                    end

                    esp.Name.Visible = true
                    esp.Name.Color = Color3.fromRGB(255, 60, 60)
                    esp.Name.Text = model.Name .. " [" .. dist .. "s]"
                    esp.Name.Position = Vector2.new(pos2D.X, pos2D.Y - 50)

                    local currentMoney, remainingGen = getPrinterStats(entry, now)
                    esp.Stats.Visible = true
                    esp.Stats.Text = remainingGen and string.format("Has: %s | Left: %s", currentMoney, remainingGen) or string.format("Has: %s", currentMoney)
                    esp.Stats.Position = Vector2.new(pos2D.X, pos2D.Y - 33)

                    drawingIndex = drawingIndex + 1
                end
            elseif not entry.IsQuality and genEnabled and dist <= genMaxDist then
                genFoundCount = genFoundCount + 1
                if onScreen then
                    local esp = getOrCreateESPObject(drawingIndex)
                    
                    if genBoxEnabled then
                        esp.Box.Visible = true
                        esp.Box.Color = Color3.fromRGB(0, 170, 255)
                        esp.Box.Position = Vector2.new(pos2D.X - 25, pos2D.Y - 25)
                        esp.Box.Size = Vector2.new(50, 50)
                    end

                    esp.Name.Visible = true
                    esp.Name.Color = Color3.fromRGB(0, 170, 255)
                    esp.Name.Text = model.Name .. " [" .. dist .. "s]"
                    esp.Name.Position = Vector2.new(pos2D.X, pos2D.Y - 50)

                    local currentMoney, remainingGen = getPrinterStats(entry, now)
                    esp.Stats.Visible = true
                    esp.Stats.Text = remainingGen and string.format("Has: %s | Left: %s", currentMoney, remainingGen) or string.format("Has: %s", currentMoney)
                    esp.Stats.Position = Vector2.new(pos2D.X, pos2D.Y - 33)

                    drawingIndex = drawingIndex + 1
                end
            end
        end
    end

    if qualFoundCount > 0 then
        qualStatusText.Text = string.format("Status: Found %d printer(s)", qualFoundCount)
        qualStatusText.Color = Color3.fromRGB(0, 255, 100)
    else
        qualStatusText.Text = "Status: [No Printers]"
        qualStatusText.Color = Color3.fromRGB(150, 150, 160)
    end

    if genFoundCount > 0 then
        genStatusText.Text = string.format("Status: Found %d printer(s)", genFoundCount)
        genStatusText.Color = Color3.fromRGB(0, 255, 100)
    else
        genStatusText.Text = "Status: [No Printers]"
        genStatusText.Color = Color3.fromRGB(150, 150, 160)
    end
end)
