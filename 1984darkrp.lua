-- Safe cleanup of old drawings and connections if re-executed
pcall(function()
    if _G.PrinterESPConn then _G.PrinterESPConn:Disconnect() end
    if _G.PrinterClickConn then _G.PrinterClickConn:Disconnect() end
    if _G.GenBox then _G.GenBox:Remove() end
    if _G.GenText then _G.GenText:Remove() end
    if _G.QualBox then _G.QualBox:Remove() end
    if _G.QualText then _G.QualText:Remove() end
    if _G.MainBorder then _G.MainBorder:Remove() end
    if _G.MainBg then _G.MainBg:Remove() end
    if _G.TitleText then _G.TitleText:Remove() end
    if _G.GenBtnBg then _G.GenBtnBg:Remove() end
    if _G.GenBtnText then _G.GenBtnText:Remove() end
    if _G.GenBoxBtnBg then _G.GenBoxBtnBg:Remove() end
    if _G.GenBoxBtnText then _G.GenBoxBtnText:Remove() end
    if _G.GenSliderBg then _G.GenSliderBg:Remove() end
    if _G.GenSliderFill then _G.GenSliderFill:Remove() end
    if _G.GenSliderKnob then _G.GenSliderKnob:Remove() end
    if _G.GenSliderText then _G.GenSliderText:Remove() end
    if _G.QualHeaderText then _G.QualHeaderText:Remove() end
    if _G.QualBtnBg then _G.QualBtnBg:Remove() end
    if _G.QualBtnText then _G.QualBtnText:Remove() end
    if _G.QualBoxBtnBg then _G.QualBoxBtnBg:Remove() end
    if _G.QualBoxBtnText then _G.QualBoxBtnText:Remove() end
    if _G.QualSliderBg then _G.QualSliderBg:Remove() end
    if _G.QualSliderFill then _G.QualSliderFill:Remove() end
    if _G.QualSliderKnob then _G.QualSliderKnob:Remove() end
    if _G.QualSliderText then _G.QualSliderText:Remove() end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- Settings state
local genEnabled = true
local genBoxEnabled = true
local genMaxDist = 500

local qualEnabled = true
local qualBoxEnabled = true
local qualMaxDist = 500

-- ESP Drawings for Generic
local genBox = Drawing.new("Square")
genBox.Visible = false
genBox.Color = Color3.fromRGB(0, 170, 255)
genBox.Thickness = 2
genBox.Filled = false
_G.GenBox = genBox

local genText = Drawing.new("Text")
genText.Visible = false
genText.Color = Color3.fromRGB(0, 170, 255)
genText.Size = 16
genText.Center = true
genText.Outline = true
_G.GenText = genText

-- ESP Drawings for Quality
local qualBox = Drawing.new("Square")
qualBox.Visible = false
qualBox.Color = Color3.fromRGB(255, 50, 50)
qualBox.Thickness = 2
qualBox.Filled = false
_G.QualBox = qualBox

local qualText = Drawing.new("Text")
qualText.Visible = false
qualText.Color = Color3.fromRGB(255, 50, 50)
qualText.Size = 16
qualText.Center = true
qualText.Outline = true
_G.QualText = qualText

-- UI Window Geometry (Position: X: 30, Y: 100, Width: 200, Height: 265)
local winX, winY, winW, winH = 30, 100, 200, 265

-- Window Border
local mainBorder = Drawing.new("Square")
mainBorder.Visible = true
mainBorder.Position = Vector2.new(winX - 1, winY - 1)
mainBorder.Size = Vector2.new(winW + 2, winH + 2)
mainBorder.Color = Color3.fromRGB(40, 40, 50)
mainBorder.Filled = true
_G.MainBorder = mainBorder

-- Window Background
local mainBg = Drawing.new("Square")
mainBg.Visible = true
mainBg.Position = Vector2.new(winX, winY)
mainBg.Size = Vector2.new(winW, winH)
mainBg.Color = Color3.fromRGB(20, 20, 25)
mainBg.Filled = true
_G.MainBg = mainBg

-- Title Text
local titleText = Drawing.new("Text")
titleText.Visible = true
titleText.Position = Vector2.new(winX + 10, winY + 8)
titleText.Size = 14
titleText.Color = Color3.fromRGB(200, 200, 210)
titleText.Outline = true
titleText.Text = "1984 Printer ESP"
_G.TitleText = titleText

-- ==================== SECTION 1: GENERIC PRINTERS ====================
local genHeader = Drawing.new("Text")
genHeader.Visible = true
genHeader.Position = Vector2.new(winX + 10, winY + 30)
genHeader.Size = 12
genHeader.Color = Color3.fromRGB(0, 170, 255)
genHeader.Outline = true
genHeader.Text = "-- [ Generic Printers ] --"
_G.GenHeader = genHeader

local genBtnBg = Drawing.new("Square")
local genBtnText = Drawing.new("Text")
local genBoxBtnBg = Drawing.new("Square")
local genBoxBtnText = Drawing.new("Text")
local genSliderBg = Drawing.new("Square")
local genSliderFill = Drawing.new("Square")
local genSliderKnob = Drawing.new("Square")
local genSliderText = Drawing.new("Text")

-- ==================== SECTION 2: QUALITY PRINTERS ====================
local qualHeader = Drawing.new("Text")
qualHeader.Visible = true
qualHeader.Size = 12
qualHeader.Color = Color3.fromRGB(255, 50, 50)
qualHeader.Outline = true
qualHeader.Text = "-- [ Quality Printers ] --"
_G.QualHeaderText = qualHeader

local qualBtnBg = Drawing.new("Square")
local qualBtnText = Drawing.new("Text")
local qualBoxBtnBg = Drawing.new("Square")
local qualBoxBtnText = Drawing.new("Text")
local qualSliderBg = Drawing.new("Square")
local qualSliderFill = Drawing.new("Square")
local qualSliderKnob = Drawing.new("Square")
local qualSliderText = Drawing.new("Text")

-- Set initial properties for all elements
for _, obj in pairs({genBtnBg, genBoxBtnBg, qualBtnBg, qualBoxBtnBg}) do
    obj.Visible = true
    obj.Size = Vector2.new(180, 22)
    obj.Color = Color3.fromRGB(30, 30, 38)
    obj.Filled = true
end

for _, txt in pairs({genBtnText, genBoxBtnText, qualBtnText, qualBoxBtnText}) do
    txt.Visible = true
    txt.Size = 12
    txt.Center = true
    txt.Outline = true
    txt.Color = Color3.fromRGB(0, 255, 100)
end
genBtnText.Text = "ESP: [ON]"
genBoxBtnText.Text = "Box ESP: [ON]"
qualBtnText.Text = "ESP: [ON]"
qualBoxBtnText.Text = "Box ESP: [ON]"

for _, sBg in pairs({genSliderBg, qualSliderBg}) do
    sBg.Visible = true
    sBg.Size = Vector2.new(180, 5)
    sBg.Color = Color3.fromRGB(40, 40, 50)
    sBg.Filled = true
end

for _, sFill in pairs({genSliderFill, qualSliderFill}) do
    sFill.Visible = true
    sFill.Size = Vector2.new(180, 5)
    sFill.Color = Color3.fromRGB(0, 170, 255)
    sFill.Filled = true
end

for _, sKnob in pairs({genSliderKnob, qualSliderKnob}) do
    sKnob.Visible = true
    sKnob.Size = Vector2.new(6, 13)
    sKnob.Color = Color3.fromRGB(255, 255, 255)
    sKnob.Filled = true
end

for _, sTxt in pairs({genSliderText, qualSliderText}) do
    sTxt.Visible = true
    sTxt.Size = 11
    sTxt.Color = Color3.fromRGB(180, 180, 190)
    sTxt.Outline = true
end

_G.GenBtnBg = genBtnBg
_G.GenBtnText = genBtnText
_G.GenBoxBtnBg = genBoxBtnBg
_G.GenBoxBtnText = genBoxBtnText
_G.GenSliderBg = genSliderBg
_G.GenSliderFill = genSliderFill
_G.GenSliderKnob = genSliderKnob
_G.GenSliderText = genSliderText

_G.QualBtnBg = qualBtnBg
_G.QualBtnText = qualBtnText
_G.QualBoxBtnBg = qualBoxBtnBg
_G.QualBoxBtnText = qualBoxBtnText
_G.QualSliderBg = qualSliderBg
_G.QualSliderFill = qualSliderFill
_G.QualSliderKnob = qualSliderKnob
_G.QualSliderText = qualSliderText

-- Interaction States
local isDraggingWindow = false
local activeSlider = nil -- "gen" or "qual"
local windowOffset = Vector2.new(0, 0)
local wasMousePressed = false
local lastClick = 0

-- Handle Input, Dragging, Clicking, and Sliders
_G.PrinterClickConn = RunService.RenderStepped:Connect(function()
    local mouseX, mouseY = mouse.X, mouse.Y
    local mousePressed = ismouse1pressed()

    -- Coordinate Layout Bounds relative to winX, winY
    -- Generic Section
    local gBtnX, gBtnY = winX + 10, winY + 48
    local gBoxBtnX, gBoxBtnY = winX + 10, winY + 74
    local gSliderX, gSliderY = winX + 10, winY + 112

    -- Quality Section
    local qHeaderY = winY + 134
    local qBtnX, qBtnY = winX + 10, winY + 152
    local qBoxBtnX, qBoxBtnY = winX + 10, winY + 178
    local qSliderX, qSliderY = winX + 10, winY + 216

    -- Hitboxes
    local inTitleBar = mouseX >= winX and mouseX <= winX + winW and mouseY >= winY and mouseY <= winY + 25
    local inGenBtn = mouseX >= gBtnX and mouseX <= gBtnX + 180 and mouseY >= gBtnY and mouseY <= gBtnY + 22
    local inGenBoxBtn = mouseX >= gBoxBtnX and mouseX <= gBoxBtnX + 180 and mouseY >= gBoxBtnY and mouseY <= gBoxBtnY + 22
    local inGenSlider = mouseX >= gSliderX - 5 and mouseX <= gSliderX + 185 and mouseY >= gSliderY - 10 and mouseY <= gSliderY + 18

    local inQualBtn = mouseX >= qBtnX and mouseX <= qBtnX + 180 and mouseY >= qBtnY and mouseY <= qBtnY + 22
    local inQualBoxBtn = mouseX >= qBoxBtnX and mouseX <= qBoxBtnX + 180 and mouseY >= qBoxBtnY and mouseY <= qBoxBtnY + 22
    local inQualSlider = mouseX >= qSliderX - 5 and mouseX <= qSliderX + 185 and mouseY >= qSliderY - 10 and mouseY <= qSliderY + 18

    if mousePressed then
        if not wasMousePressed then
            if inTitleBar then
                isDraggingWindow = true
                windowOffset = Vector2.new(mouseX - winX, mouseY - winY)
            elseif inGenSlider then
                activeSlider = "gen"
            elseif inQualSlider then
                activeSlider = "qual"
            end
        end

        if isDraggingWindow then
            winX = mouseX - windowOffset.X
            winY = mouseY - windowOffset.Y
        elseif activeSlider == "gen" then
            local percent = math.clamp((mouseX - gSliderX) / 180, 0, 1)
            genMaxDist = math.floor(10 + (percent * 9990))
        elseif activeSlider == "qual" then
            local percent = math.clamp((mouseX - qSliderX) / 180, 0, 1)
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
                    if not genEnabled then genBox.Visible = false; genText.Visible = false end
                elseif inGenBoxBtn then
                    lastClick = tick()
                    genBoxEnabled = not genBoxEnabled
                    genBoxBtnText.Color = genBoxEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
                    genBoxBtnText.Text = genBoxEnabled and "Box ESP: [ON]" or "Box ESP: [OFF]"
                    if not genBoxEnabled then genBox.Visible = false end
                elseif inQualBtn then
                    lastClick = tick()
                    qualEnabled = not qualEnabled
                    qualBtnText.Color = qualEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
                    qualBtnText.Text = qualEnabled and "ESP: [ON]" or "ESP: [OFF]"
                    if not qualEnabled then qualBox.Visible = false; qualText.Visible = false end
                elseif inQualBoxBtn then
                    lastClick = tick()
                    qualBoxEnabled = not qualBoxEnabled
                    qualBoxBtnText.Color = qualBoxEnabled and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(255, 50, 50)
                    qualBoxBtnText.Text = qualBoxEnabled and "Box ESP: [ON]" or "Box ESP: [OFF]"
                    if not qualBoxEnabled then qualBox.Visible = false end
                end
            end
        end

        isDraggingWindow = false
        activeSlider = nil
    end

    wasMousePressed = mousePressed

    -- Recalculate visual UI component positions
    gBtnX, gBtnY = winX + 10, winY + 48
    gBoxBtnX, gBoxBtnY = winX + 10, winY + 74
    gSliderX, gSliderY = winX + 10, winY + 112

    qHeaderY = winY + 134
    qBtnX, qBtnY = winX + 10, winY + 152
    qBoxBtnX, qBoxBtnY = winX + 10, winY + 178
    qSliderX, qSliderY = winX + 10, winY + 216

    mainBorder.Position = Vector2.new(winX - 1, winY - 1)
    mainBg.Position = Vector2.new(winX, winY)
    titleText.Position = Vector2.new(winX + 10, winY + 8)

    -- Generic Elements Update
    genHeader.Position = Vector2.new(winX + 10, winY + 30)
    genBtnBg.Position = Vector2.new(gBtnX, gBtnY)
    genBtnText.Position = Vector2.new(gBtnX + 90, gBtnY + 4)
    genBoxBtnBg.Position = Vector2.new(gBoxBtnX, gBoxBtnY)
    genBoxBtnText.Position = Vector2.new(gBoxBtnX + 90, gBoxBtnY + 4)
    genSliderBg.Position = Vector2.new(gSliderX, gSliderY)
    genSliderFill.Position = Vector2.new(gSliderX, gSliderY)

    local gPercent = math.clamp((genMaxDist - 10) / 9990, 0, 1)
    local gFillW = math.clamp(180 * gPercent, 2, 180)
    genSliderFill.Size = Vector2.new(gFillW, 5)
    genSliderKnob.Position = Vector2.new(gSliderX + gFillW - 3, gSliderY - 4)
    genSliderText.Position = Vector2.new(gSliderX, gSliderY - 15)
    genSliderText.Text = string.format("Max Distance: %d studs", genMaxDist)

    -- Quality Elements Update
    qualHeader.Position = Vector2.new(winX + 10, qHeaderY)
    qualBtnBg.Position = Vector2.new(qBtnX, qBtnY)
    qualBtnText.Position = Vector2.new(qBtnX + 90, qBtnY + 4)
    qualBoxBtnBg.Position = Vector2.new(qBoxBtnX, qBoxBtnY)
    qualBoxBtnText.Position = Vector2.new(qBoxBtnX + 90, qBoxBtnY + 4)
    qualSliderBg.Position = Vector2.new(qSliderX, qSliderY)
    qualSliderFill.Position = Vector2.new(qSliderX, qSliderY)

    local qPercent = math.clamp((qualMaxDist - 10) / 9990, 0, 1)
    local qFillW = math.clamp(180 * qPercent, 2, 180)
    qualSliderFill.Size = Vector2.new(qFillW, 5)
    qualSliderKnob.Position = Vector2.new(qSliderX + qFillW - 3, qSliderY - 4)
    qualSliderText.Position = Vector2.new(qSliderX, qSliderY - 15)
    qualSliderText.Text = string.format("Max Distance: %d studs", qualMaxDist)
end)

-- Main ESP Render Loop for Both Categories
_G.PrinterESPConn = RunService.RenderStepped:Connect(function()
    local cargoFolder = workspace:FindFirstChild("Cargo")
    if not cargoFolder or not localPlayer.Character or not localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        genBox.Visible = false; genText.Visible = false
        qualBox.Visible = false; qualText.Visible = false
        return
    end

    local rootPos = localPlayer.Character.HumanoidRootPart.Position

    local foundGen = nil
    local genShortest = genMaxDist + 1

    local foundQual = nil
    local qualShortest = qualMaxDist + 1

    for _, model in ipairs(cargoFolder:GetChildren()) do
        if model:IsA("Model") then
            local nameLower = model.Name:lower()
            local targetPart = model:FindFirstChild("Center") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

            if targetPart then
                local dist = math.floor((rootPos - targetPart.Position).Magnitude)

                -- Differentiate Quality vs Generic Printers
                if string.find(nameLower, "quality") or model.Name == "Quality Money Printer" then
                    if dist < qualShortest then
                        qualShortest = dist
                        foundQual = {model = model, part = targetPart, dist = dist}
                    end
                elseif string.find(nameLower, "printer") or string.find(nameLower, "money") then
                    if dist < genShortest then
                        genShortest = dist
                        foundGen = {model = model, part = targetPart, dist = dist}
                    end
                end
            end
        end
    end

    -- Render Generic ESP
    if genEnabled and foundGen and foundGen.dist <= genMaxDist then
        local pos, onScreen = WorldToScreen(foundGen.part.Position)
        if onScreen then
            if genBoxEnabled then
                genBox.Visible = true
                genBox.Position = Vector2.new(pos.X - 25, pos.Y - 25)
                genBox.Size = Vector2.new(50, 50)
            else
                genBox.Visible = false
            end
            genText.Visible = true
            genText.Text = foundGen.model.Name .. " [" .. foundGen.dist .. "s]"
            genText.Position = Vector2.new(pos.X, pos.Y - 45)
        else
            genBox.Visible = false
            genText.Visible = false
        end
    else
        genBox.Visible = false
        genText.Visible = false
    end

    -- Render Quality ESP
    if qualEnabled and foundQual and foundQual.dist <= qualMaxDist then
        local pos, onScreen = WorldToScreen(foundQual.part.Position)
        if onScreen then
            if qualBoxEnabled then
                qualBox.Visible = true
                qualBox.Position = Vector2.new(pos.X - 25, pos.Y - 25)
                qualBox.Size = Vector2.new(50, 50)
            else
                qualBox.Visible = false
            end
            qualText.Visible = true
            qualText.Text = foundQual.model.Name .. " [" .. foundQual.dist .. "s]"
            qualText.Position = Vector2.new(pos.X, pos.Y - 45)
        else
            qualBox.Visible = false
            qualText.Visible = false
        end
    else
        qualBox.Visible = false
        qualText.Visible = false
    end
end)
