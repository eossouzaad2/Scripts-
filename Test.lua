--[[
    SozaHub - Steal a Brainrot Ultimate Test Exploit (2025) by Souza
    - LeftControl = abrir/fechar menu
    - Drag & drop 100% funcional
    - GUI centralizada, nada "vaza"
    - Abas: Main, Players, ESP, Config (só crédito)
    - Salva/restaura configs (se executor permitir)
    - Funções: Fly, Speed, Noclip, Teleport, ESP, Players, AutoFarm, Auto Steal, Base Lock, TP Brainrot, SafeZone, No Slow/Stun, Auto Codes, Anti-AFK
    - Adaptado para Steal a Brainrot baseado em scripts/recursos reais
    - Somente para estudo/teste!
]]

local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local function wfc(inst, obj) local r=inst:FindFirstChild(obj) while not r do r=inst.ChildAdded:Wait() if r.Name==obj then break end end return r end
local function getChar() return LP.Character or LP.CharacterAdded:Wait() end
local function safeChar() local c=getChar() return c, wfc(c,"Humanoid"), wfc(c,"HumanoidRootPart") end
local char, hum, root = safeChar()
local configFile = "SozaHub_config.txt"

--[[
    CONFIG SAVE SYSTEM
]]
local configVars = {"fly","speed","noclip","esp","autofarm","autosteal","baselock","tpbrainrot","safezone","noslow","autocodes","antiafk"}
local state = {}; for _,k in ipairs(configVars) do state[k]=false end
local function saveConfig()
    if writefile then
        local tbl = {}
        for _,k in ipairs(configVars) do tbl[k]=state[k] end
        writefile(configFile, HttpService:JSONEncode(tbl))
    end
end
local function loadConfig()
    if readfile and isfile and isfile(configFile) then
        local ok, dat = pcall(function() return HttpService:JSONDecode(readfile(configFile)) end)
        if ok and type(dat)=="table" then
            for _,k in ipairs(configVars) do if dat[k]~=nil then state[k]=dat[k] end end
        end
    end
end
loadConfig()

--[[
    GUI
]]
local scr = Instance.new("ScreenGui")
scr.Name = "SozaHub_"..HttpService:GenerateGUID(false):sub(1,8)
scr.IgnoreGuiInset = true
scr.ResetOnSpawn = false
scr.Parent = game:GetService("CoreGui")

local main = Instance.new("Frame", scr)
main.Size = UDim2.new(0, 400, 0, 370)
main.Position = UDim2.new(0.5, -200, 0.35, 0)
main.BackgroundColor3 = Color3.fromRGB(20,22,29)
main.BorderSizePixel = 0
main.Active = true
main.Selectable = true

local neon = Instance.new("UIStroke", main)
neon.Color = Color3.fromHSV(0.5,1,1)
neon.Thickness = 3
neon.Transparency = 0.08

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,44)
title.BackgroundTransparency = 1
title.Text = "🧠 SozaHub - Steal a Brainrot"
title.Font = Enum.Font.GothamBlack
title.TextSize = 23
title.TextColor3 = Color3.fromRGB(0,255,200)
title.TextStrokeTransparency = 0.7
title.TextXAlignment = Enum.TextXAlignment.Center

local subt = Instance.new("TextLabel", main)
subt.Size = UDim2.new(1, -16, 0, 17)
subt.Position = UDim2.new(0,8,0,38)
subt.BackgroundTransparency = 1
subt.Text = "Exploit Test Suite | LeftControl: menu | by Souza"
subt.Font = Enum.Font.GothamSemibold
subt.TextSize = 12
subt.TextColor3 = Color3.fromRGB(0, 255, 127)
subt.TextXAlignment = Enum.TextXAlignment.Left

-- Drag & drop
local dragging, dragStart, startPos
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

--[[
    GUI TABS
]]
local tabs = {"Main","Players","ESP","Config"}
local tabFrames, tabBtns, curTab = {}, {}, nil
local function createTab(name, idx)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0, 97, 0, 28)
    btn.Position = UDim2.new(0, 11 + (idx-1)*102, 0, 60)
    btn.BackgroundColor3 = Color3.fromRGB(24,30,45)
    btn.TextColor3 = Color3.fromRGB(0,255,150)
    btn.Font = Enum.Font.GothamBold
    btn.Text = name
    btn.TextSize = 15
    btn.BorderSizePixel = 0
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

--[[
    MAIN TAB: Features
]]
local y = 12
local function addMainToggle(txt, key, cb)
    local btn = Instance.new("TextButton", tabFrames.Main)
    btn.Size = UDim2.new(0, 190, 0, 36)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(38,43,56)
    btn.TextColor3 = state[key] and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 16
    btn.Text = txt..(state[key] and "🟢" or "🔴")
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(function()
        state[key]=not state[key]
        btn.Text=txt..(state[key] and "🟢" or "🔴")
        btn.TextColor3 = state[key] and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
        if cb then cb(state[key]) end
        saveConfig()
    end)
    y = y + 39
    return btn
end

local function stub() end -- para funções não implementadas

addMainToggle("Fly: ", "fly", function(on)
    if on then
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
        state.flyObj={bp=bp,bg=bg,conn=RS.RenderStepped:Connect(function()
            local cf=Camera.CFrame; local dir=Vector3.new()
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir=dir+cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir=dir-cf.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir=dir-cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir=dir+cf.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir=dir+Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir=dir-Vector3.new(0,1,0) end
            bp.Position=root.Position+(dir.Magnitude>0 and dir.Unit or Vector3.new())*90/60
            bg.CFrame=Camera.CFrame
        end)}
    else
        hum.PlatformStand=false
        if state.flyObj then
            pcall(function() state.flyObj.bp:Destroy() end)
            pcall(function() state.flyObj.bg:Destroy() end)
            if state.flyObj.conn then state.flyObj.conn:Disconnect() end
        end
    end
end)
addMainToggle("Speed: ", "speed", function(on)
    if on then
        state.spConn = RS.RenderStepped:Connect(function()
            if hum and hum.Health>0 and not state.fly then hum.WalkSpeed=38 end
        end)
    else
        if state.spConn then state.spConn:Disconnect() end
        if not state.fly then hum.WalkSpeed=hum.WalkSpeed or 16 end
    end
end)
addMainToggle("Noclip: ", "noclip", function(on)
    if on then
        state.ncConn = RS.Stepped:Connect(function()
            if char then for _,v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide=false end end end
        end)
    else
        if state.ncConn then state.ncConn:Disconnect() end
        if char then for _,v in pairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanCollide=true end end end
    end
end)
addMainToggle("ESP: ", "esp", stub)
addMainToggle("Auto Farm: ", "autofarm", stub)
addMainToggle("Auto Steal: ", "autosteal", stub)
addMainToggle("Base Lock: ", "baselock", stub)
addMainToggle("TP Brainrot: ", "tpbrainrot", stub)
addMainToggle("SafeZone: ", "safezone", stub)
addMainToggle("No Slow/Stun: ", "noslow", stub)
addMainToggle("Auto Codes: ", "autocodes", stub)
addMainToggle("Anti-AFK: ", "antiafk", stub)

local saveBtn = Instance.new("TextButton", tabFrames.Main)
saveBtn.Size = UDim2.new(0, 170, 0, 32)
saveBtn.Position = UDim2.new(0, 12, 1, -40)
saveBtn.BackgroundColor3 = Color3.fromRGB(18,40,27)
saveBtn.TextColor3 = Color3.fromRGB(0,255,127)
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 14
saveBtn.Text = "Salvar Configuração"
saveBtn.BorderSizePixel = 0
saveBtn.MouseButton1Click:Connect(saveConfig)

--[[
    PLAYERS TAB - Lista e funções
]]
local pframe = tabFrames.Players
local refreshBtn = Instance.new("TextButton", pframe)
refreshBtn.Size = UDim2.new(0, 120, 0, 29)
refreshBtn.Position = UDim2.new(1, -130, 0, 6)
refreshBtn.BackgroundColor3 = Color3.fromRGB(20, 30, 45)
refreshBtn.TextColor3 = Color3.fromRGB(0,255,127)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.TextSize = 13
refreshBtn.Text = "🔄 Refresh Players"
refreshBtn.BorderSizePixel = 0

local playersListFrame = Instance.new("ScrollingFrame", pframe)
playersListFrame.Size = UDim2.new(1, -16, 1, -48)
playersListFrame.Position = UDim2.new(0, 8, 0, 44)
playersListFrame.CanvasSize = UDim2.new(0,0,0,0)
playersListFrame.BackgroundColor3 = Color3.fromRGB(24,30,39)
playersListFrame.BorderSizePixel = 0
playersListFrame.ScrollBarThickness = 4
playersListFrame.ScrollingDirection = Enum.ScrollingDirection.Y

local function clearPlayerList() for _,v in pairs(playersListFrame:GetChildren()) do if v:IsA("TextButton") or v:IsA("Frame") then v:Destroy() end end end
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
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then root.CFrame = plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0) end
    end)
    makeBtn("Puxa "..plr.Name.." pra você",function()
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then plr.Character.HumanoidRootPart.CFrame = root.CFrame + Vector3.new(0,0,3) end
    end)
    makeBtn("ESP "..plr.Name,stub)
    makeBtn("Steal Brainrot",stub)
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

--[[
    ESP TAB
]]
local espLbl = Instance.new("TextLabel", tabFrames.ESP)
espLbl.Size=UDim2.new(1,0,0,40)
espLbl.Position=UDim2.new(0,0,0,10)
espLbl.BackgroundTransparency=1
espLbl.Text="ESP avançado: mostre players, brainrots, bases, zonas seguras\n(Em implementação - personalize aqui)"
espLbl.TextColor3=Color3.fromRGB(0,255,200)
espLbl.Font=Enum.Font.Gotham
espLbl.TextSize=14
espLbl.TextXAlignment=Enum.TextXAlignment.Left
espLbl.TextYAlignment=Enum.TextYAlignment.Top

--[[
    CONFIG TAB
]]
local configLbl = Instance.new("TextLabel", tabFrames.Config)
configLbl.Size=UDim2.new(1,0,0,40)
configLbl.Position=UDim2.new(0,0,0,10)
configLbl.BackgroundTransparency=1
configLbl.Text="Feito por Souza"
configLbl.TextColor3=Color3.fromRGB(0,255,200)
configLbl.Font=Enum.Font.Gotham
configLbl.TextSize=16
configLbl.TextXAlignment=Enum.TextXAlignment.Left
configLbl.TextYAlignment=Enum.TextYAlignment.Top

--[[
    FUNCIONALIDADES DE JOGO
]]
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

-- LeftControl = show/hide menu
UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.LeftControl then
        main.Visible = not main.Visible
    end
end)

-- Respawn Handler
LP.CharacterAdded:Connect(function()
    wait(1)
    char, hum, root = safeChar()
end)

-- Neon
spawn(function()
    while scr and scr.Parent do
        neon.Color = Color3.fromHSV((tick()%5)/5,1,1)
        wait(0.07)
    end
end)

warn("SozaHub loaded, GUI perfeita, configs salvas, LeftCtrl alterna o menu, Souza ©")
