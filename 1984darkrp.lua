-- Clean up old drawings and connections if re-executed
if _G.CargoDrawingESP then
    pcall(function() _G.CargoDrawingESP:Disconnect() end)
    pcall(function() _G.CargoDrawingClick:Disconnect() end)
    pcall(function() _G.CargoBox:Remove() end)
    pcall(function() _G.CargoText:Remove() end)
    pcall(function() _G.BtnBorder:Remove() end)
    pcall(function() _G.BtnBg:Remove() end)
    pcall(function() _G.BtnText:Remove() end)
end

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

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

-- Cool Modern UI Toggle Button (Initial Position: X: 30, Y: 100)
local btnX, btnY, btnW, btnH = 30, 100, 130, 38

-- Outer Border
local btnBorder = Drawing.new("Square")
btnBorder.Visible = true
btnBorder.Position = Vector2.new(btnX - 1, btnY - 1)
btnBorder.Size = Vector2.new(btnW + 2, btnH + 2)
btnBorder.Color = Color3.fromRGB(40, 40, 50)
btnBorder.Filled = true
_G.BtnBorder = btnBorder

-- Dark Background
local btnBg = Drawing.new("Square")
btnBg.Visible = true
btnBg.Position = Vector2.new(btnX, btnY)
btnBg.Size = Vector2.new(btnW, btnH)
btnBg.Color = Color3.fromRGB(20, 20, 25)
btnBg.Filled = true
_G.BtnBg = btnBg

-- Button Text Label
local btnText = Drawing.new("Text")
btnText.Visible = true
btnText.Position = Vector2.new(btnX + (btnW / 2), btnY + 9)
btnText.Center = true
btnText.Size = 15
btnText.Color = Color3.fromRGB(0, 255, 100)
btnText.Outline = true
btnText.Text = "ESP: [ON]"
_G.BtnText = btnText

local espEnabled = true
local isDragging = false
local dragOffset = Vector2.new(0, 0)
local lastClick = 0

-- Handle Dragging, Hover Effects, and Clicking
_G.CargoDrawingClick = RunService.RenderStepped:Connect(function()
    local mouseX, mouseY = mouse.X, mouse.Y
    local mousePressed = ismouse1pressed()

    local isHovering = mouseX >= btnX and mouseX <= btnX + btnW and mouseY >= btnY and mouseY <= btnY + btnH

    if mousePressed then
        if not isDragging and isHovering then
            isDragging = true
            dragOffset = Vector2.new(mouseX - btnX, mouseY - btnY)
        elseif isDragging then
            btnX = mouseX - dragOffset.X
            btnY = mouseY - dragOffset.Y
        end
    else
        if isDragging then
            isDragging = false
            if isHovering and tick() - lastClick > 0.3 then
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
    end

    btnBorder.Position = Vector2.new(btnX - 1, btnY - 1)
    btnBg.Position = Vector2.new(btnX, btnY)
    btnText.Position = Vector2.new(btnX + (btnW / 2), btnY + 9)
end)

-- Main ESP Render Loop
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
        local pos, onScreen = WorldToScreen(targetPart.Position)
        
        if onScreen then
            local dist = math.floor((localPlayer.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude)
            
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
end)