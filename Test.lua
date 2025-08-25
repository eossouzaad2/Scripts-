--[[
    SozaHub - Ultra Exploit Test Script v1.0
    Foco: Testes de anti-cheat no Steal a Braintot
    Features: Fly, Speed, Noclip, Teleport, Menu Neon, Player List, ESP, Teleport/Puxar, Heartbeat, Drag GUI, Modular
    Use apenas para estudo/teste. NÃO para uso malicioso.
--]]

-- Obfuscation helpers
local HttpService = game:GetService("HttpService")
local function rid() return HttpService:GenerateGUID(false):gsub("-", "") end
local _v = {}; for _,v in pairs({"fly","speed","noclip","esp","tele","menu","drag","players","state","gui","root","hum","heartbeat","espConns"}) do _v[v]=rid() end

local UIS, Players, RS = game:GetService("UserInputService"), game:GetService("Players"), game:GetService("RunService")
local LP, Camera = Players.LocalPlayer, workspace.CurrentCamera
local char, hum, root = LP.Character or LP.CharacterAdded:Wait(), nil, nil
local function updateChar() char=LP.Character; hum=char:WaitForChild("Humanoid"); root=char:WaitForChild("HumanoidRootPart") end
updateChar()

-- Estado dos módulos
local state = {[_v.fly]=false,[_v.speed]=false,[_v.noclip]=false,[_v.esp]=false}
local flySpeed, walkSpeed, normalSpeed = 90, 38, 16
local guiName = "SozaHub_"..rid()
local dragData = {dragging=false,dx=0,dy=0}
local espBoxes, espConns = {}, {}

-- GUI principal
local scr = Instance.new("ScreenGui")
scr.Name = guiName
scr.IgnoreGuiInset = true
scr.ResetOnSpawn = false
scr.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 370, 0, 340)
main.Position = UDim2.new(0.5, -185, 0.33, 0)
main.BackgroundColor3 = Color3.fromRGB(20,23,33)
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.Active = true
main.ZIndex = 10
main.Parent = scr

local neon = Instance.new("UIStroke", main)
neon.Color = Color3.fromHSV(math.random(),1,1)
neon.Thickness = 4
neon.Transparency = 0.2

-- Título
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🧠 SozaHub - Steal a Braintot"
title.Font = Enum.Font.GothamBlack
title.TextSize = 23
title.TextColor3 = Color3.fromRGB(0,255,200)
title.TextStrokeTransparency = 0.7

local subt = Instance.new("TextLabel", main)
subt.Size = UDim2.new(1, -20, 0, 18)
subt.Position = UDim2.new(0,10,0,36)
subt.BackgroundTransparency = 1
subt.Text = "Ultra Exploit (test) | Foco: anti-cheat | Neon UI | Players Hub | "..rid():sub(1,4)
subt.Font = Enum.Font.GothamSemibold
subt.TextSize = 13
subt.TextColor3 = Color3.fromRGB(0, 255, 127)
subt.TextXAlignment = Enum.TextXAlignment.Left

-- Drag
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragData.dragging=true; dragData.dx=input.Position.X-main.Position.X.Offset; dragData.dy=input.Position.Y-main.Position.Y.Offset end
end)
main.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragData.dragging=false end end)
UIS.InputChanged:Connect(function(input)
    if dragData.dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        main.Position = UDim2.new(0, input.Position.X - dragData.dx, 0, input.Position.Y - dragData.dy)
    end
end)

-- Aba de navegação
local tabs = {"Main","Players","ESP","Config"}
local tabFrames, tabBtns, curTab = {}, {}, nil
local function createTab(name, idx)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 90, 0, 26)
    btn.Position = UDim2.new(0, 15 + (idx-1)*92, 0, 60)
    btn.BackgroundColor3 = Color3.fromRGB(24,30,45)
    btn.TextColor3 = Color3.fromRGB(0,255,150)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextSize = 15
    btn.BorderSizePixel = 0
    btn.ZIndex = 11
    tabBtns[name] = btn
    local frame = Instance.new("Frame", main)
    frame.Size = UDim2.new(1, -20, 1, -100)
    frame.Position = UDim2.new(0, 10, 0, 95)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    tabFrames[name] = frame
    btn.MouseButton1Click:Connect(function()
        if curTab then tabFrames[curTab].Visible=false; tabBtns[curTab].TextColor3=Color3.fromRGB(0,255,150) end
        curTab = name
        frame.Visible=true; btn.TextColor3=Color3.fromRGB(255,255,255)
    end)
end
for i,t in ipairs(tabs) do createTab(t,i) end
tabFrames["Main"].Visible=true; curTab="Main"; tabBtns["Main"].TextColor3=Color3.fromRGB(255,255,255)

-- Main Tab: Exploits
local y = 15
local function addMainBtn(txt, key, onClick)
    local b = Instance.new("TextButton", tabFrames.Main)
    b.Size = UDim2.new(0, 170, 0, 38)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(39, 43, 56)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 17
    b.Text = txt
    b.BorderSizePixel = 0
    b.ZIndex = 12
    b.Name = key
    local st = Instance.new("UIStroke", b)
    st.Color = Color3.fromRGB(0,255,127)
    st.Thickness = 1.2
    st.Transparency = 0.7
    b.MouseButton1Click:Connect(onClick)
    y = y + 44
    return b
end
local mainBtns = {
    fly = addMainBtn("Fly: 🔴", "fly", function() SozaHubModules.fly.toggle() end),
    speed = addMainBtn("Speed: 🔴", "speed", function() SozaHubModules.speed.toggle() end),
    noclip = addMainBtn("Noclip: 🔴", "noclip", function() SozaHubModules.noclip.toggle() end),
    teleport = addMainBtn("Q+W/S Teleport", "teleport", function() end),
    destroy = addMainBtn("💥 Auto-destruir SozaHub", "destroy", function() scr:Destroy() warn("SozaHub destroyed") end),
}
local info = Instance.new("TextLabel", tabFrames.Main)
info.Size = UDim2.new(1, -10, 0, 66)
info.Position = UDim2.new(0, 0, 1, -66)
info.BackgroundTransparency = 1
info.Text = "Q+W: Teleporta pra frente\nQ+S: Teleporta pra trás\nMenu: RightCtrl\n"
info.TextColor3 = Color3.fromRGB(120,255,180)
info.Font = Enum.Font.GothamSemibold
info.TextSize = 14
info.TextXAlignment = Enum.TextXAlignment.Left
info.TextYAlignment = Enum.TextYAlignment.Top

-- ESP Tab: global ESP (todos players)
local espBtn = Instance.new("TextButton", tabFrames.ESP)
espBtn.Size = UDim2.new(0, 190, 0, 38)
espBtn.Position = UDim2.new(0, 10, 0, 20)
espBtn.BackgroundColor3 = Color3.fromRGB(39, 43, 56)
espBtn.TextColor3 = Color3.fromRGB(255,255,255)
espBtn.Font = Enum.Font.Gotham
espBtn.TextSize = 17
espBtn.Text = "ESP Global: 🔴"
espBtn.BorderSizePixel = 0
espBtn.MouseButton1Click:Connect(function() SozaHubModules.esp.toggle() end)

-- Players Tab
local playersFrame = tabFrames.Players
local refreshBtn = Instance.new("TextButton", playersFrame)
refreshBtn.Size = UDim2.new(0, 120, 0, 32)
refreshBtn.Position = UDim2.new(1, -140, 0, 6)
refreshBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
refreshBtn.TextColor3 = Color3.fromRGB(0,255,127)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 15
refreshBtn.Text = "🔄 Refresh Players"
refreshBtn.BorderSizePixel = 0

local playersListFrame = Instance.new("ScrollingFrame", playersFrame)
playersListFrame.Size = UDim2.new(1, -16, 1, -48)
playersListFrame.Position = UDim2.new(0, 8, 0, 44)
playersListFrame.CanvasSize = UDim2.new(0,0,0,0)
playersListFrame.BackgroundColor3 = Color3.fromRGB(24,30,39)
playersListFrame.BorderSizePixel = 0
playersListFrame.ScrollBarThickness = 4
playersListFrame.ScrollingDirection = Enum.ScrollingDirection.Y

local function clearPlayerList()
    for _,v in pairs(playersListFrame:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("Frame") then v:Destroy() end
    end
end

local function playerESPBox(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = plr.Character.HumanoidRootPart
    box.AlwaysOnTop=true
    box.ZIndex=10
    box.Size = Vector3.new(3,6,3)
    box.Color3 = Color3.fromRGB(0,255,127)
    box.Transparency = 0.6
    box.Parent = workspace
    table.insert(espBoxes, box)
    -- Nome acima
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = plr.Character.HumanoidRootPart
    billboard.Size = UDim2.new(0,100,0,30)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0,4,0)
    local lbl = Instance.new("TextLabel", billboard)
    lbl.Size=UDim2.new(1,0,1,0)
    lbl.Text=plr.Name
    lbl.TextColor3=Color3.fromRGB(0,255,127)
    lbl.BackgroundTransparency=1
    lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=16
    billboard.Parent = workspace
    table.insert(espBoxes, billboard)
end
local function clearESP() for _,v in ipairs(espBoxes) do pcall(function() v:Destroy() end) end; espBoxes={} end

local function playerMenu(plr)
    local menu = Instance.new("Frame", scr)
    menu.Size = UDim2.new(0, 200, 0, 170)
    menu.Position = UDim2.new(0, main.AbsolutePosition.X+main.AbsoluteSize.X+9, 0, main.AbsolutePosition.Y)
    menu.BackgroundColor3 = Color3.fromRGB(13,22,43)
    menu.BorderSizePixel = 0
    local neon2 = Instance.new("UIStroke", menu)
    neon2.Color = Color3.fromRGB(0,255,127)
    neon2.Thickness = 2
    local t = Instance.new("TextLabel", menu)
    t.Size=UDim2.new(1,0,0,36)
    t.BackgroundTransparency=1
    t.Text = "Player: "..plr.Name
    t.TextColor3 = Color3.fromRGB(0,255,127)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 19
    local y2=40
    local function makeBtn(txt,callback)
        local b=Instance.new("TextButton",menu)
        b.Size=UDim2.new(1,-20,0,34)
        b.Position=UDim2.new(0,10,0,y2)
        b.BackgroundColor3=Color3.fromRGB(24,30,45)
        b.TextColor3=Color3.fromRGB(255,255,255)
        b.Font=Enum.Font.Gotham
        b.Text=txt
        b.TextSize=16
        b.BorderSizePixel=0
        b.MouseButton1Click:Connect(function() callback(); menu:Destroy() end)
        y2=y2+38
    end
    makeBtn("Teleporta pra "..plr.Name,function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            root.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
        end
    end)
    makeBtn("Puxa "..plr.Name.." pra você",function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            plr.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0,0,3)
        end
    end)
    makeBtn("ESP "..plr.Name,function() playerESPBox(plr) end)
    makeBtn("Fechar",function() end)
end

local function updatePlayerList()
    clearPlayerList()
    local listY=0
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP then
            local b=Instance.new("TextButton",playersListFrame)
            b.Size=UDim2.new(1,-10,0,32)
            b.Position=UDim2.new(0,5,0,listY)
            b.BackgroundColor3=Color3.fromRGB(39,43,56)
            b.TextColor3=Color3.fromRGB(255,255,255)
            b.Font=Enum.Font.Gotham
            b.Text=plr.Name
            b.TextSize=15
            b.BorderSizePixel=0
            b.MouseButton1Click:Connect(function() playerMenu(plr) end)
            listY=listY+36
        end
    end
    playersListFrame.CanvasSize=UDim2.new(0,0,0,listY+5)
end
refreshBtn.MouseButton1Click:Connect(updatePlayerList)
updatePlayerList()

-- Config Tab (ajuste)
local configLbl = Instance.new("TextLabel", tabFrames.Config)
configLbl.Size=UDim2.new(1,0,0,60)
configLbl.Position=UDim2.new(0,0,0,10)
configLbl.BackgroundTransparency=1
configLbl.Text="SozaHub v1.0\nPara testes de anti-cheat em Steal a Braintot.\nInspirado em exploits reais, mas seguro para estudo."
configLbl.TextColor3=Color3.fromRGB(0,255,200)
configLbl.Font=Enum.Font.Gotham
configLbl.TextSize=16
configLbl.TextXAlignment=Enum.TextXAlignment.Left
configLbl.TextYAlignment=Enum.TextYAlignment.Top

-- Modular Exploit System
SozaHubModules = {}
-- Fly
function SozaHubModules.fly.toggle()
    state[_v.fly]=not state[_v.fly]
    mainBtns.fly.Text="Fly: "..(state[_v.fly] and "🟢" or "🔴")
    mainBtns.fly.TextColor3=state[_v.fly] and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    if state[_v.fly] then
        hum.PlatformStand=true
        local bp=Instance.new("BodyPosition",root)
        bp.MaxForce=Vector3.new(1e5,1e5,1e5)
        bp.P=9e4
        bp.D=1000
        bp.Position=root.Position
        local bg=Instance.new("BodyGyro",root)
        bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
        bg.CFrame=root.CFrame
        bg.P=9e4
        SozaHubModules.fly._bp=bp; SozaHubModules.fly._bg=bg;
        SozaHubModules.fly._conn=RS.RenderStepped:Connect(function()
            local cf=Camera.CFrame; local dir=Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
            bp.Position=root.Position+(dir.Magnitude>0 and dir.Unit or Vector3.new())*flySpeed/60
            bg.CFrame=Camera.CFrame
        end)
    else
        hum.PlatformStand=false
        pcall(function() SozaHubModules.fly._bp:Destroy() end)
        pcall(function() SozaHubModules.fly._bg:Destroy() end)
        if SozaHubModules.fly._conn then SozaHubModules.fly._conn:Disconnect() end
    end
end
-- Speed
function SozaHubModules.speed.toggle()
    state[_v.speed]=not state[_v.speed]
    mainBtns.speed.Text="Speed: "..(state[_v.speed] and "🟢" or "🔴")
    mainBtns.speed.TextColor3=state[_v.speed] and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    if state[_v.speed] then
        if SozaHubModules.speed._conn then SozaHubModules.speed._conn:Disconnect() end
        SozaHubModules.speed._conn=RS.RenderStepped:Connect(function()
            if hum and hum.Health>0 and not state[_v.fly] then hum.WalkSpeed=walkSpeed end
        end)
    else
        if SozaHubModules.speed._conn then SozaHubModules.speed._conn:Disconnect() end
        if not state[_v.fly] then hum.WalkSpeed=normalSpeed end
    end
end
-- Noclip
function SozaHubModules.noclip.toggle()
    state[_v.noclip]=not state[_v.noclip]
    mainBtns.noclip.Text="Noclip: "..(state[_v.noclip] and "🟢" or "🔴")
    mainBtns.noclip.TextColor3=state[_v.noclip] and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    if state[_v.noclip] then
        if SozaHubModules.noclip._conn then SozaHubModules.noclip._conn:Disconnect() end
        SozaHubModules.noclip._conn=RS.Stepped:Connect(function()
            if char and state[_v.noclip] then for _,v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide=false end end end
        end)
    else
        if SozaHubModules.noclip._conn then SozaHubModules.noclip._conn:Disconnect() end
        if char then for _,v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide=true end end end
    end
end
-- ESP (global)
function SozaHubModules.esp.toggle()
    state[_v.esp]=not state[_v.esp]
    espBtn.Text="ESP Global: "..(state[_v.esp] and "🟢" or "🔴")
    espBtn.TextColor3=state[_v.esp] and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    clearESP()
    if state[_v.esp] then
        for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP then playerESPBox(plr) end end
        espConns.players=Players.PlayerAdded:Connect(function(plr) task.wait(1); if plr~=LP then playerESPBox(plr) end end)
        espConns.char=Players.PlayerRemoving:Connect(function(plr) clearESP() end)
    else
        for _,v in pairs(espConns) do if v then v:Disconnect() end end
        espConns={}
        clearESP()
    end
end

-- Teleport Q+W/Q+S
local qDown,wDown,sDown=false,false,false
UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==Enum.KeyCode.Q then qDown=true end
    if i.KeyCode==Enum.KeyCode.W then wDown=true end
    if i.KeyCode==Enum.KeyCode.S then sDown=true end
    if qDown and wDown then root.CFrame=root.CFrame+(Camera.CFrame.LookVector*15) end
    if qDown and sDown then root.CFrame=root.CFrame+(-Camera.CFrame.LookVector*15) end
end)
UIS.InputEnded:Connect(function(i)
    if i.KeyCode==Enum.KeyCode.Q then qDown=false end
    if i.KeyCode==Enum.KeyCode.W then wDown=false end
    if i.KeyCode==Enum.KeyCode.S then sDown=false end
end)

-- Heartbeat (obfuscação dinâmica)
spawn(function()
    while scr and scr.Parent do
        neon.Color = Color3.fromHSV(tick()%5/5,1,1)
        scr.Name=guiName..rid():sub(1,5)
        main.Name="SZ_"..rid():sub(1,6)
        wait(math.random(1,6)/10)
    end
end)

-- Respawn handler
LP.CharacterAdded:Connect(function()
    task.wait(1)
    updateChar()
    if state[_v.speed] then SozaHubModules.speed.toggle() SozaHubModules.speed.toggle() end
    if state[_v.noclip] then SozaHubModules.noclip.toggle() SozaHubModules.noclip.toggle() end
end)

-- Hide from CoreGui
for _,v in ipairs(scr:GetChildren()) do pcall(function() v.RobloxLocked=true end) end
Players.PlayerRemoving:Connect(function() updatePlayerList() end)
Players.PlayerAdded:Connect(function() task.wait(0.5); updatePlayerList() end)

warn("SozaHub loaded for anti-cheat testing - Steal a Braintot")
