-- Clean up old drawings and connections if re-executed
if _G.CargoDrawingESP then
    pcall(function() _G.CargoDrawingESP:Disconnect() end)
    pcall(function() _G.CargoDrawingClick:Disconnect() end)
    pcall(function() _G.CargoBox:Remove() end)
    pcall(function() _G.CargoText:Remove() end)
    pcall(function() _G.MainBorder:Remove() end)
    pcall(function() _G.MainBg:Remove() end)
    pcall(function() _G.TitleText:Remove() end)
    pcall(function() _G.BtnBg:Remove() end)
    pcall(function() _G.BtnText:Remove() end)
    pcall(function() _G.SliderBg:Remove() end)
    pcall(function() _G.SliderFill:Remove() end)
    pcall(function() _G.SliderKnob:Remove() end)
    pcall(function() _G.SliderText:Remove() end)
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- Settings state
local espEnabled = true
local maxDistance = 500 -- Default distance limit

-- ESP Box & Text Drawings
local box = Drawing.new("Square")
box.Visible = false
box.Color = Color3.fromRGB(255, 50, 50)
box.Thickness = 2
box.Filled = false
_G.CargoBox = box

local text = Drawing.new("Text")
text.Visible = false
text.Color = Color3.fromRGB(255, 255, 255)
text.Size = 16
text.Center = true
text.Outline = true
_G.CargoText = text

-- UI Window Geometry (Position: X: 30, Y: 100, Width: 180, Height: 115)
local winX, winY, winW, winH = 30, 100, 180, 115

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
titleText.Text = "Cargo ESP Control"
_G.TitleText = titleText

-- Toggle Button
local btnX, btnY, btnW, btnH = winX + 10, winY + 30, 160, 26
local btnBg = Drawing.new("Square")
btnBg.Visible = true
btnBg.Position = Vector2.new(btnX, btnY)
btnBg.Size = Vector2.new(btnW, btnH)
btnBg.Color = Color3.fromRGB(30, 30, 38)
btnBg.Filled = true
_G.BtnBg = btnBg

local btnText = Drawing.new("Text")
btnText.Visible = true
btnText.Position = Vector2.new(btnX + (btnW / 2), btnY + 5)
btnText.Center = true
btnText.Size = 14
btnText.Color = Color3.fromRGB(0, 255, 100)
btnText.Outline = true
btnText.Text = "ESP: [ON]"
_G.BtnText = btnText

-- Distance Slider Geometry
local sliderX, sliderY, sliderW, sliderH = winX + 10, winY + 80, 160, 6
local sliderBg = Drawing.new("Square")
sliderBg.Visible = true
sliderBg.Position = Vector2.new(sliderX, sliderY)
sliderBg.Size = Vector2.new(sliderW, sliderH)
sliderBg.Color = Color3.fromRGB(40, 40, 50)
sliderBg.Filled = true
_G.SliderBg = sliderBg

local sliderFill = Drawing.new("Square")
sliderFill.Visible = true
sliderFill.Position = Vector2.new(sliderX, sliderY)
sliderFill.Size = Vector2.new(sliderW, sliderH)
sliderFill.Color = Color3.fromRGB(0, 170, 255)
sliderFill.Filled = true
_G.SliderFill = sliderFill

local sliderKnob = Drawing.new("Square")
sliderKnob.Visible = true
sliderKnob.Size = Vector2.new(8, 14)
sliderKnob.Color = Color3.fromRGB(255, 255, 255)
sliderKnob.Filled = true
_G.SliderKnob = sliderKnob

local sliderText = Drawing.new("Text")
sliderText.Visible = true
sliderText.Position = Vector2.new(sliderX, sliderY - 15)
sliderText.Size = 13
sliderText.Color = Color3.fromRGB(180, 180, 190)
sliderText.Outline = true
sliderText.Text = "Max Distance: 500 studs"
_G.SliderText = sliderText

-- Interaction States
local isDraggingWindow = false
local isDraggingSlider = false
local windowOffset = Vector2.new(0, 0)
local lastClick = 0

-- Handle Input, Dragging, Clicking, and Slider Control
_G.CargoDrawingClick = RunService.RenderStepped:Connect(function()
    local mouseX, mouseY = mouse.X, mouse.Y
    local mousePressed = ismouse1pressed()

    -- Always update component offsets relative to current winX/winY FIRST so hitboxes match visual positions
    btnX, btnY = winX + 10, winY + 30
    sliderX, sliderY = winX + 10, winY + 80

    -- Hitboxes
    local inTitleBar = mouseX >= winX and mouseX <= winX + winW and mouseY >= winY and mouseY <= winY + 25
    local inButton = mouseX >= btnX and mouseX <= btnX + btnW and mouseY >= btnY and mouseY <= btnY + btnH
    local inSliderZone = mouseX >= sliderX - 10 and mouseX <= sliderX + sliderW + 10 and mouseY >= sliderY - 15 and mouseY <= sliderY + 20

    if mousePressed then
        if not isDraggingWindow and not isDraggingSlider then
            if inTitleBar then
                isDraggingWindow = true
                windowOffset = Vector2.new(mouseX - winX, mouseY - winY)
            elseif inSliderZone then
                isDraggingSlider = true
            end
        elseif isDraggingWindow then
            winX = mouseX - windowOffset.X
            winY = mouseY - windowOffset.Y
        elseif isDraggingSlider then
            local percent = math.clamp((mouseX - sliderX) / sliderW, 0, 1)
            maxDistance = math.floor(10 + (percent * 9990))
        end
    else
        if isDraggingWindow then
            isDraggingWindow = false
        end
        if isDraggingSlider then
            isDraggingSlider = false
        end

        -- Handle button click for toggle
        if inButton and tick() - lastClick > 0.3 then
            lastClick = tick()
            espEnabled = not espEnabled
            if espEnabled then
                btnText.Color = Color3.fromRGB(0, 255, 100)
                btnText.Text = "ESP: [ON]"
            else
                btnText.Color = Color3.fromRGB(255, 50, 50)
                btnText.Text = "ESP: [OFF]"
                box.Visible = false
                text.Visible = false
            end
        end
    end

    -- Recalculate component positions again after window movement
    btnX, btnY = winX + 10, winY + 30
    sliderX, sliderY = winX + 10, winY + 80

    mainBorder.Position = Vector2.new(winX - 1, winY - 1)
    mainBg.Position = Vector2.new(winX, winY)
    titleText.Position = Vector2.new(winX + 10, winY + 8)

    btnBg.Position = Vector2.new(btnX, btnY)
    btnText.Position = Vector2.new(btnX + (btnW / 2), btnY + 5)

    sliderBg.Position = Vector2.new(sliderX, sliderY)
    sliderFill.Position = Vector2.new(sliderX, sliderY)

    local currentPercent = math.clamp((maxDistance - 10) / 9990, 0, 1)
    local fillWidth = math.clamp(sliderW * currentPercent, 2, sliderW)
    
    sliderFill.Size = Vector2.new(fillWidth, sliderH)
    sliderKnob.Position = Vector2.new(sliderX + fillWidth - 4, sliderY - 4)
    sliderText.Position = Vector2.new(sliderX, sliderY - 15)
    sliderText.Text = string.format("Max Distance: %d studs", maxDistance)
end)

-- Main ESP Render Loop with Dynamic Slider Limit
_G.CargoDrawingESP = RunService.RenderStepped:Connect(function()
    if not espEnabled then 
        box.Visible = false
        text.Visible = false
        return 
    end

    local cargoFolder = workspace:FindFirstChild("Cargo")
    local model = cargoFolder and cargoFolder:FindFirstChild("Quality Money Printer")
    local targetPart = model and model:FindFirstChild("Center")

    if targetPart and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = math.floor((localPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude)
        
        if dist <= maxDistance then
            local pos, onScreen = WorldToScreen(targetPart.Position)
            
            if onScreen then
                box.Visible = true
                box.Position = Vector2.new(pos.X - 25, pos.Y - 25)
                box.Size = Vector2.new(50, 50)
                
                text.Visible = true
                text.Text = model.Name .. " [" .. dist .. " studs]"
                text.Position = Vector2.new(pos.X, pos.Y - 45)
            else
                box.Visible = false
                text.Visible = false
            end
        else
            box.Visible = false
            text.Visible = false
        end
    else
        box.Visible = false
        text.Visible = false
    end
end)
