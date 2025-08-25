-- SozaHub GUI Exploit Test - Corrigido, funcional, com interface profissional e drag&drop

-- Helpers
local HttpService = game:GetService("HttpService")
local function rid() return HttpService:GenerateGUID(false):gsub("-", "") end
local UIS, Players, RS = game:GetService("UserInputService"), game:GetService("Players"), game:GetService("RunService")
local LP, Camera = Players.LocalPlayer, workspace.CurrentCamera

local function waitForChar()
    local c = LP.Character or LP.CharacterAdded:Wait()
    repeat wait() until c:FindFirstChild("Humanoid") and c:FindFirstChild("HumanoidRootPart")
    return c, c.Humanoid, c.HumanoidRootPart
end
local char, hum, root = waitForChar()

-- Estado dos módulos
local state = {fly=false, speed=false, noclip=false, esp=false}
local flySpeed, walkSpeed, normalSpeed = 90, 38, hum.WalkSpeed
local espBoxes, espConns = {}, {}
local dragging, dragInput, dragStart, startPos

-- GUI principal
local scr = Instance.new("ScreenGui")
scr.Name = "SozaHub_"..rid()
scr.IgnoreGuiInset = true
scr.ResetOnSpawn = false
scr.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 390, 0, 350)
main.Position = UDim2.new(0.5, -195, 0.33, 0)
main.BackgroundColor3 = Color3.fromRGB(18,22,29)
main.BackgroundTransparency = 0
main.BorderSizePixel = 0
main.Active = true
main.Selectable = true
main.Parent = scr

local neon = Instance.new("UIStroke", main)
neon.Color = Color3.fromRGB(0,255,200)
neon.Thickness = 3
neon.Transparency = 0.1

-- Drag & drop funcional
main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Título
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 44)
title.BackgroundTransparency = 1
title.Text = "🧠 SozaHub - Steal a Braintot"
title.Font = Enum.Font.GothamBlack
title.TextSize = 23
title.TextColor3 = Color3.fromRGB(0,255,200)
title.TextStrokeTransparency = 0.7

local subt = Instance.new("TextLabel", main)
subt.Size = UDim2.new(1, -16, 0, 18)
subt.Position = UDim2.new(0,8,0,37)
subt.BackgroundTransparency = 1
subt.Text = "Ultra Exploit (test) | Foco: anti-cheat | Neon UI | Players Hub"
subt.Font = Enum.Font.GothamSemibold
subt.TextSize = 13
subt.TextColor3 = Color3.fromRGB(0, 255, 127)
subt.TextXAlignment = Enum.TextXAlignment.Left

-- Abas
local tabs = {"Main","Players","ESP","Config"}
local tabFrames, tabBtns, curTab = {}, {}, nil
local function createTab(name, idx)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 92, 0, 28)
    btn.Position = UDim2.new(0, 11 + (idx-1)*97, 0, 60)
    btn.BackgroundColor3 = Color3.fromRGB(24,30,45)
    btn.TextColor3 = Color3.fromRGB(0,255,150)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextSize = 15
    btn.BorderSizePixel = 0
    btn.ZIndex = 11
    tabBtns[name] = btn
    local frame = Instance.new("Frame", main)
    frame.Size = UDim2.new(1, -22, 1, -100)
    frame.Position = UDim2.new(0, 11, 0, 95)
    frame.BackgroundTransparency = 1
    frame.Visible = false
    tabFrames[name] = frame
    btn.MouseButton1Click:Connect(function()
        for _,t in ipairs(tabs) do tabFrames[t].Visible = false; tabBtns[t].TextColor3 = Color3.fromRGB(0,255,150) end
        curTab = name
        frame.Visible=true; btn.TextColor3=Color3.fromRGB(255,255,255)
    end)
end
for i,t in ipairs(tabs) do createTab(t,i) end
tabFrames["Main"].Visible=true; curTab="Main"; tabBtns["Main"].TextColor3=Color3.fromRGB(255,255,255)

-- Main Tab: Exploits
local mainBtns = {}
local y = 16
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
    mainBtns[key] = b
    y = y + 44
    return b
end
addMainBtn("Fly: 🔴", "fly", function()
    state.fly = not state.fly
    mainBtns.fly.Text = "Fly: "..(state.fly and "🟢" or "🔴")
    mainBtns.fly.TextColor3 = state.fly and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    if state.fly then
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
        mainBtns.bp=bp; mainBtns.bg=bg
        mainBtns.flyConn=RS.RenderStepped:Connect(function()
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
        pcall(function() mainBtns.bp:Destroy() end)
        pcall(function() mainBtns.bg:Destroy() end)
        if mainBtns.flyConn then mainBtns.flyConn:Disconnect() end
    end
end)
addMainBtn("Speed: 🔴", "speed", function()
    state.speed = not state.speed
    mainBtns.speed.Text = "Speed: "..(state.speed and "🟢" or "🔴")
    mainBtns.speed.TextColor3 = state.speed and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    if state.speed then
        if mainBtns.speedConn then mainBtns.speedConn:Disconnect() end
        mainBtns.speedConn = RS.RenderStepped:Connect(function()
            if hum and hum.Health>0 and not state.fly then hum.WalkSpeed = walkSpeed end
        end)
    else
        if mainBtns.speedConn then mainBtns.speedConn:Disconnect() end
        if not state.fly then hum.WalkSpeed = normalSpeed end
    end
end)
addMainBtn("Noclip: 🔴", "noclip", function()
    state.noclip = not state.noclip
    mainBtns.noclip.Text = "Noclip: "..(state.noclip and "🟢" or "🔴")
    mainBtns.noclip.TextColor3 = state.noclip and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    if state.noclip then
        if mainBtns.noclipConn then mainBtns.noclipConn:Disconnect() end
        mainBtns.noclipConn = RS.Stepped:Connect(function()
            if char and state.noclip then for _,v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide=false end end end
        end)
    else
        if mainBtns.noclipConn then mainBtns.noclipConn:Disconnect() end
        if char then for _,v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide=true end end end
    end
end)
addMainBtn("Q+W/S Teleport", "teleport", function() end)
addMainBtn("💥 Auto-destruir SozaHub", "destroy", function() scr:Destroy() warn("SozaHub destroyed") end)

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
espBtn.Size = UDim2.new(0, 200, 0, 38)
espBtn.Position = UDim2.new(0, 10, 0, 20)
espBtn.BackgroundColor3 = Color3.fromRGB(39, 43, 56)
espBtn.TextColor3 = Color3.fromRGB(255,255,255)
espBtn.Font = Enum.Font.Gotham
espBtn.TextSize = 17
espBtn.Text = "ESP Global: 🔴"
espBtn.BorderSizePixel = 0

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

espBtn.MouseButton1Click:Connect(function()
    state.esp = not state.esp
    espBtn.Text="ESP Global: "..(state.esp and "🟢" or "🔴")
    espBtn.TextColor3 = state.esp and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    clearESP()
    if state.esp then
        for _,plr in ipairs(Players:GetPlayers()) do if plr~=LP then playerESPBox(plr) end end
        if espConns.players then espConns.players:Disconnect() end
        if espConns.char then espConns.char:Disconnect() end
        espConns.players=Players.PlayerAdded:Connect(function(plr) task.wait(1); if plr~=LP then playerESPBox(plr) end end)
        espConns.char=Players.PlayerRemoving:Connect(function(plr) clearESP() end)
    else
        for _,v in pairs(espConns) do if v then v:Disconnect() end end
        espConns={}
        clearESP()
    end
end)

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
Players.PlayerRemoving:Connect(function() updatePlayerList() end)
Players.PlayerAdded:Connect(function() wait(0.5); updatePlayerList() end)

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

-- Menu Toggle (RightCtrl)
UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.RightControl then
        main.Visible = not main.Visible
    end
end)

-- Respawn Handler
LP.CharacterAdded:Connect(function()
    wait(1)
    char, hum, root = waitForChar()
    normalSpeed = hum.WalkSpeed
    if state.speed then mainBtns.speed.MouseButton1Click:Fire() mainBtns.speed.MouseButton1Click:Fire() end
    if state.noclip then mainBtns.noclip.MouseButton1Click:Fire() mainBtns.noclip.MouseButton1Click:Fire() end
end)

-- Neon animado
spawn(function()
    while scr and scr.Parent do
        neon.Color = Color3.fromHSV((tick()%5)/5,1,1)
        wait(0.07)
    end
end)

warn("SozaHub loaded and GUI fully functional!")
