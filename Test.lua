--[[
   Ultra Advanced Script - Obfuscated, Dynamic, Anti-cheat Challenge
   Features: Fly, Speed, Noclip, Teleport, Drag GUI, Animated Neon Menu, Dynamic Obfuscation, Heartbeat, Anti-detection
   Test only in safe environments!
]]

local http = game:GetService("HttpService")
local rand = function() return http:GenerateGUID(false):gsub("-", "") end

local _vars = {}
for _,v in ipairs({"fly","speed","noclip","tele","menu","drag","state","statetxt","btn","anim","heartbeat","gui","root","hum"}) do
    _vars[v] = rand()
end

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local char = LP.Character or LP.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

local state = {
    [_vars.fly] = false,
    [_vars.speed] = false,
    [_vars.noclip] = false,
}
local flySpeed, walkSpeed, normalSpeed = 90, 38, hum.WalkSpeed
local guiName = "UltraMenu_"..rand()
local dragData = {dragging=false,dx=0,dy=0}

-- GUI
local scr = Instance.new("ScreenGui")
scr.Name = guiName
scr.ResetOnSpawn = false
scr.IgnoreGuiInset = true
scr.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 270)
main.Position = UDim2.new(0.5, -150, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(21,22,28)
main.BorderSizePixel = 0
main.BackgroundTransparency = 0.12
main.Visible = true
main.Active = true
main.Draggable = false
main.Parent = scr

local neon = Instance.new("UIStroke")
neon.Color = Color3.fromRGB(0,255,127)
neon.Thickness = 3
neon.Parent = main

local shadow = Instance.new("ImageLabel")
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(-0.05, 0, -0.05, 0)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.7
shadow.ZIndex = 0
shadow.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 38)
title.BackgroundTransparency = 1
title.Text = "⚡ Ultra Hacker Menu ⚡"
title.Font = Enum.Font.GothamBlack
title.TextSize = 23
title.TextColor3 = Color3.fromRGB(0,255,127)
title.TextStrokeTransparency = 0.85
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -18, 0, 20)
subtitle.Position = UDim2.new(0, 9, 0, 34)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Fly | Speed | Noclip | Teleport | Drag | Anti-Detect"
subtitle.Font = Enum.Font.GothamSemibold
subtitle.TextSize = 15
subtitle.TextColor3 = Color3.fromRGB(156,255,200)
subtitle.TextStrokeTransparency = 0.7
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

-- Drag logic
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = true
        dragData.dx = input.Position.X - main.Position.X.Offset
        dragData.dy = input.Position.Y - main.Position.Y.Offset
    end
end)
main.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragData.dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragData.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        main.Position = UDim2.new(0, input.Position.X - dragData.dx, 0, input.Position.Y - dragData.dy)
    end
end)

-- BTN creation
local y = 62
local btns, anims = {}, {}
local function makeBtn(txt, key)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -34, 0, 38)
    b.Position = UDim2.new(0, 17, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(39, 43, 56)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 18
    b.Text = txt
    b.AutoButtonColor = false
    b.BorderSizePixel = 0
    b.Parent = main
    b.Name = key
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0,255,127)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.7
    stroke.Parent = b
    btns[key] = b
    y = y + 41
    return b
end

local function statusIcon(on)
    return on and "🟢" or "🔴"
end

makeBtn("Fly: "..statusIcon(false), _vars.fly)
makeBtn("Super Speed: "..statusIcon(false), _vars.speed)
makeBtn("Noclip: "..statusIcon(false), _vars.noclip)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 56)
info.Position = UDim2.new(0, 10, 0, y)
info.BackgroundTransparency = 1
info.Text = "Q+W: Teleport Forward\nQ+S: Teleport Backward\nDrag menu by mouse\nMenu: RightCtrl"
info.TextColor3 = Color3.fromRGB(120,255,180)
info.Font = Enum.Font.GothamSemibold
info.TextSize = 15
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top
info.Parent = main

-- Menu minimize
local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 26)
minBtn.Position = UDim2.new(1, -38, 0, 6)
minBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
minBtn.BackgroundTransparency = 0.3
minBtn.TextColor3 = Color3.fromRGB(0,255,127)
minBtn.Text = "_"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 20
minBtn.ZIndex = 20
minBtn.Parent = main

local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    main.Size = minimized and UDim2.new(0,300,0,40) or UDim2.new(0,300,0,270)
    for k,btn in pairs(btns) do btn.Visible = not minimized end
    info.Visible = not minimized
    minBtn.Text = minimized and "▣" or "_"
end)

-- Animated neon border
spawn(function()
    while main and main.Parent do
        neon.Color = Color3.fromHSV(tick()%5/5,1,1)
        wait(0.08)
    end
end)

-- MENU TOGGLE
UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

-- FLY
local flyConn, flyBP, flyBG
local function setFly(on)
    state[_vars.fly] = on
    btns[_vars.fly].Text = "Fly: "..statusIcon(on)
    btns[_vars.fly].TextColor3 = on and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    if on then
        hum.PlatformStand = true
        flyBP = Instance.new("BodyPosition")
        flyBP.MaxForce = Vector3.new(1e5,1e5,1e5)
        flyBP.P = 9e4
        flyBP.D = 1000
        flyBP.Position = root.Position
        flyBP.Parent = root
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
        flyBG.CFrame = root.CFrame
        flyBG.P = 9e4
        flyBG.Parent = root
        flyConn = RS.RenderStepped:Connect(function()
            local cf = Camera.CFrame
            local dir = Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + (cf.LookVector) end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - (cf.LookVector) end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - (cf.RightVector) end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + (cf.RightVector) end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
            flyBP.Position = root.Position + (dir.Magnitude>0 and dir.Unit or Vector3.new()) * flySpeed/60
            flyBG.CFrame = Camera.CFrame
        end)
        hum.StateChanged:Connect(function(_,new)
            if not state[_vars.fly] then return end
            if new == Enum.HumanoidStateType.Seated or new == Enum.HumanoidStateType.Climbing then
                hum.PlatformStand = true
            end
        end)
    else
        hum.PlatformStand = false
        if flyBP then pcall(function() flyBP:Destroy() end) end
        if flyBG then pcall(function() flyBG:Destroy() end) end
        if flyConn then pcall(function() flyConn:Disconnect() end) flyConn = nil end
    end
end
btns[_vars.fly].MouseButton1Click:Connect(function() setFly(not state[_vars.fly]) end)

-- SPEED
local speedConn
local function setSpeed(on)
    state[_vars.speed] = on
    btns[_vars.speed].Text = "Super Speed: "..statusIcon(on)
    btns[_vars.speed].TextColor3 = on and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    if on then
        if speedConn then speedConn:Disconnect() end
        speedConn = RS.RenderStepped:Connect(function()
            if hum and hum.Parent and hum.Health>0 and not state[_vars.fly] then
                hum.WalkSpeed = walkSpeed
            end
        end)
    else
        if speedConn then speedConn:Disconnect() speedConn=nil end
        if not state[_vars.fly] then hum.WalkSpeed = normalSpeed end
    end
end
btns[_vars.speed].MouseButton1Click:Connect(function() setSpeed(not state[_vars.speed]) end)

-- NOCLIP
local noclipConn
local function setNoclip(on)
    state[_vars.noclip] = on
    btns[_vars.noclip].Text = "Noclip: "..statusIcon(on)
    btns[_vars.noclip].TextColor3 = on and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    if on then
        if noclipConn then noclipConn:Disconnect() end
        noclipConn = RS.Stepped:Connect(function()
            if char and state[_vars.noclip] then
                for _,v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn=nil end
        if char then
            for _,v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end
btns[_vars.noclip].MouseButton1Click:Connect(function() setNoclip(not state[_vars.noclip]) end)

-- TELEPORT Q+W/Q+S
local qDown, wDown, sDown = false, false, false
UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Q then qDown = true end
    if i.KeyCode == Enum.KeyCode.W then wDown = true end
    if i.KeyCode == Enum.KeyCode.S then sDown = true end
    if qDown and wDown then
        if root and char and hum.Health>0 then
            local v = Camera.CFrame.LookVector * 15
            root.CFrame = root.CFrame + Vector3.new(v.X, 0, v.Z)
        end
    elseif qDown and sDown then
        if root and char and hum.Health>0 then
            local v = -Camera.CFrame.LookVector * 15
            root.CFrame = root.CFrame + Vector3.new(v.X, 0, v.Z)
        end
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Q then qDown = false end
    if i.KeyCode == Enum.KeyCode.W then wDown = false end
    if i.KeyCode == Enum.KeyCode.S then sDown = false end
end)

-- Heartbeat anti-removal
spawn(function()
    while scr and scr.Parent do
        scr.Name = guiName..rand():sub(1,6)
        main.Name = "M_"..rand():sub(1,6)
        wait(math.random(1,6)/10)
    end
end)

-- Self-repair on respawn
LP.CharacterAdded:Connect(function(c)
    char = c
    hum = c:WaitForChild("Humanoid")
    root = c:WaitForChild("HumanoidRootPart")
    normalSpeed = hum.WalkSpeed
    if state[_vars.speed] then setSpeed(true) end
    if state[_vars.noclip] then setNoclip(true) end
end)

-- Hide coregui traces (basic anti-detect)
for _,v in ipairs(scr:GetChildren()) do
    pcall(function() v.RobloxLocked = true end)
end

-- Remove traces if kicked/teleported
LP.OnTeleport:Connect(function()
    if scr then pcall(function() scr:Destroy() end) end
end)

print("Ultra Advanced Menu loaded. Test your anti-cheat against it!")
