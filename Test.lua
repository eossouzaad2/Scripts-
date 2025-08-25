--[[
  Test Toolkit (Somente para seu jogo/ambiente de testes)
  Coloque este LocalScript em: StarterPlayer > StarterPlayerScripts

  Controles:
    P -> Fly ON/OFF
    L -> Velocidade ON/OFF
    Q + W -> Teleporta 15 studs para frente
    Q + S -> Teleporta 15 studs para trás
]]

-- =======================
-- CONFIGURAÇÕES
-- =======================
local SPEED_DEFAULT = 16         -- WalkSpeed normal
local SPEED_TURBO   = 36         -- WalkSpeed quando turbo ligado
local FLY_SPEED     = 60         -- velocidade linear do fly (studs/s)
local FLY_ACCEL     = 80         -- aceleração sentida ao começar a voar (maior = mais responsivo)
local TP_DISTANCE   = 15         -- distância do teleporte (studs)
local UI_SIZE       = UDim2.fromOffset(220, 140)

-- =======================
-- SERVIÇOS
-- =======================
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local Run     = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

-- =======================
-- ESTADO
-- =======================
local state = {
    flyOn = false,
    speedOn = false,
    holdingQ = false,
    lastTpTick = 0,
    tpCooldown = 0.15, -- evita spam de teleporte
}

-- =======================
-- UTILS
-- =======================
local function getChar()
    local char = LocalPlayer.Character
    if not char or not char.Parent then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    return char, hrp, hum
end

local function safeSetSpeed(hum, speed)
    if hum and hum.Health > 0 then
        hum.WalkSpeed = math.clamp(speed, 0, 100)
    end
end

local function notify(msg)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Test Toolkit",
            Text  = tostring(msg),
            Duration = 2
        })
    end)
end

-- =======================
-- GUI (criada via código)
-- =======================
local function createUI()
    -- Remove UI antiga se existir
    local old = LocalPlayer.PlayerGui:FindFirstChild("TestToolkitGui")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "TestToolkitGui"
    gui.ResetOnSpawn = true
    gui.IgnoreGuiInset = true
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "Main"
    frame.Size = UI_SIZE
    frame.Position = UDim2.fromOffset(20, 120)
    frame.BackgroundTransparency = 0.1
    frame.AutomaticSize = Enum.AutomaticSize.None
    frame.Parent = gui

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 12)

    local padding = Instance.new("UIPadding", frame)
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)

    local list = Instance.new("UIListLayout", frame)
    list.Padding = UDim.new(0, 8)
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.SortOrder = Enum.SortOrder.LayoutOrder

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.fromOffset(200, 22)
    title.Text = "Test Toolkit"
    title.TextScaled = true
    title.BackgroundTransparency = 1
    title.Parent = frame

    local function makeButton(name, text)
        local b = Instance.new("TextButton")
        b.Name = name
        b.Size = UDim2.fromOffset(200, 30)
        b.Text = text
        b.AutoButtonColor = true
        b.Parent = frame
        local c = Instance.new("UICorner", b); c.CornerRadius = UDim.new(0, 10)
        return b
    end

    local flyBtn   = makeButton("FlyBtn",   "Fly: OFF  (P)")
    local speedBtn = makeButton("SpeedBtn", "Velocidade: OFF  (L)")

    local info = Instance.new("TextLabel")
    info.Name = "Info"
    info.Size = UDim2.fromOffset(200, 36)
    info.Text = "Q+W -> TP +15\nQ+S -> TP -15"
    info.TextScaled = true
    info.BackgroundTransparency = 1
    info.Parent = frame

    return gui, flyBtn, speedBtn
end

-- =======================
-- FLY CONTROLLER
-- =======================
local flyConn -- RenderStepped connection
local function setFly(on)
    if state.flyOn == on then return end
    state.flyOn = on

    local char, hrp, hum = getChar()
    if not (char and hrp and hum) then
        notify("Personagem inválido para Fly.")
        return
    end

    hum.PlatformStand = false
    hum:ChangeState(Enum.HumanoidStateType.Freefall) -- evita animação de correr no ar

    if on then
        local vel = Vector3.zero
        -- Atualiza a cada frame
        flyConn = Run.RenderStepped:Connect(function(dt)
            if not hrp or not hrp.Parent then return end
            -- Captura direção a partir das teclas
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += hrp.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= hrp.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += hrp.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= hrp.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end

            if dir.Magnitude > 0 then
                dir = dir.Unit
                -- aceleração simples para suavidade
                local targetVel = dir * FLY_SPEED
                vel = vel:Lerp(targetVel, math.clamp(FLY_ACCEL * dt, 0, 1))
            else
                vel = vel:Lerp(Vector3.zero, math.clamp(FLY_ACCEL * dt, 0, 1))
            end

            -- aplica velocidade diretamente ao HRP
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, vel.Y, vel.Z)
            -- opcional: mantém orientação suave (não travamos orientação para permitir olhar livre com mouse)
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        -- Ao desligar, zera a velocidade vertical para cair naturalmente
        if hrp then
            local current = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(current.X, 0, current.Z)
        end
        if hum then hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end
    end
end

-- =======================
-- SPEED CONTROLLER
-- =======================
local function setSpeed(on)
    state.speedOn = on
    local _, _, hum = getChar()
    if hum then
        safeSetSpeed(hum, on and SPEED_TURBO or SPEED_DEFAULT)
    end
end

-- Ajusta ao respawn
local function onCharacterAdded(char)
    char:WaitForChild("Humanoid")
    char:WaitForChild("HumanoidRootPart")
    -- Reaplica estados
    setSpeed(state.speedOn)
    if state.flyOn then
        setFly(false)
        task.wait(0.1)
        setFly(true)
    end
end

-- =======================
-- TELEPORTE (Q + W / Q + S)
-- =======================
local function tryTeleport(directionSign) -- 1 para frente, -1 para trás
    local t = os.clock()
    if t - state.lastTpTick < state.tpCooldown then return end
    state.lastTpTick = t

    local char, hrp, hum = getChar()
    if not (char and hrp and hum) then return end

    local look = hrp.CFrame.LookVector
    local delta = look * (TP_DISTANCE * directionSign)
    -- Teleporte seguro: mantém Y e evita clipar muito
    local newPos = hrp.Position + Vector3.new(delta.X, 0, delta.Z)
    hrp.CFrame = CFrame.new(newPos, newPos + hrp.CFrame.LookVector)
end

-- =======================
-- INPUTS
-- =======================
local gui, flyBtn, speedBtn = createUI()

local function refreshButtons()
    if flyBtn then flyBtn.Text = ("Fly: %s  (P)"):format(state.flyOn and "ON" or "OFF") end
    if speedBtn then speedBtn.Text = ("Velocidade: %s  (L)"):format(state.speedOn and "ON" or "OFF") end
end
refreshButtons()

flyBtn.MouseButton1Click:Connect(function()
    setFly(not state.flyOn)
    refreshButtons()
end)

speedBtn.MouseButton1Click:Connect(function()
    setSpeed(not state.speedOn)
    refreshButtons()
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.P then
        setFly(not state.flyOn); refreshButtons()
        notify("Fly: " .. (state.flyOn and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.L then
        setSpeed(not state.speedOn); refreshButtons()
        notify("Velocidade: " .. (state.speedOn and "ON" or "OFF"))
    elseif input.KeyCode == Enum.KeyCode.Q then
        state.holdingQ = true
    elseif input.KeyCode == Enum.KeyCode.W then
        if state.holdingQ then tryTeleport(1) end
    elseif input.KeyCode == Enum.KeyCode.S then
        if state.holdingQ then tryTeleport(-1) end
    end
end)

UIS.InputEnded:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.Q then
        state.holdingQ = false
    end
end)

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Inicializa estado ao carregar
task.defer(function()
    local _, _, hum = getChar()
    if hum then
        safeSetSpeed(hum, SPEED_DEFAULT)
    end
end)
