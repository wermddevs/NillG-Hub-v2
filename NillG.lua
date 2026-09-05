-- ============================================================
-- NILLG HUB - THE STRONGEST BATTLEGROUNDS (FLUENT UI EDITION)
-- ============================================================

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- KEY SYSTEM
-- ============================================================

local AUTH_KEY = "N_002_NLG-093d"

if not playerGui:GetAttribute("HasValidKey") then
    local authScreen = Instance.new("ScreenGui", playerGui)
    authScreen.Name = "NillGAuth"
    authScreen.ResetOnSpawn = false

    local authFrame = Instance.new("Frame", authScreen)
    authFrame.Size = UDim2.new(1, 0, 1, 0)
    authFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    authFrame.BackgroundTransparency = 0.6

    local authPanel = Instance.new("Frame", authFrame)
    authPanel.Size = UDim2.new(0, 320, 0, 180)
    authPanel.Position = UDim2.new(0.5, -160, 0.5, -90)
    authPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    authPanel.BorderSizePixel = 0
    Instance.new("UICorner", authPanel).CornerRadius = UDim.new(0, 10)

    local authText = Instance.new("TextLabel", authPanel)
    authText.Size = UDim2.new(1, 0, 0, 30)
    authText.Position = UDim2.new(0, 0, 0, 15)
    authText.Text = "🔑 COLOCAR A CHAVE"
    authText.Font = Enum.Font.GothamBold
    authText.TextSize = 18
    authText.TextColor3 = Color3.new(1, 1, 1)
    authText.BackgroundTransparency = 1

    local keyBox = Instance.new("TextBox", authPanel)
    keyBox.Size = UDim2.new(0.8, 0, 0, 36)
    keyBox.Position = UDim2.new(0.1, 0, 0, 55)
    keyBox.PlaceholderText = "Cole a chave aqui..."
    keyBox.Font = Enum.Font.Gotham
    keyBox.TextSize = 16
    keyBox.TextColor3 = Color3.new(1, 1, 1)
    keyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 6)

    local submitBtn = Instance.new("TextButton", authPanel)
    submitBtn.Size = UDim2.new(0.6, 0, 0, 36)
    submitBtn.Position = UDim2.new(0.2, 0, 0, 110)
    submitBtn.Text = "✅ SUBMIT"
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 16
    submitBtn.TextColor3 = Color3.new(1, 1, 1)
    submitBtn.BackgroundColor3 = Color3.fromRGB(90, 40, 150)
    Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 6)

    local authValid = false
    submitBtn.MouseButton1Click:Connect(function()
        if keyBox.Text == AUTH_KEY then
            playerGui:SetAttribute("HasValidKey", true)
            authValid = true
            authScreen:Destroy()
        else
            StarterGui:SetCore("SendNotification", {
                Title = "NillG Hub",
                Text = "❌ Chave incorreta! Tente novamente.",
                Duration = 3
            })
        end
    end)

    repeat task.wait() until authValid
end

-- ============================================================
-- CARREGAMENTO DA FLUENT UI
-- ============================================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ============================================================
-- VARIÁVEIS GLOBAIS
-- ============================================================

local autoReset = false
local spawnPoint = nil
local resetConnection = nil
local noclip = false
local killStat = nil
local startKills = 0

-- ============================================================
-- FUNÇÕES AUXILIARES
-- ============================================================

local function ToggleNoclip(state)
    noclip = state
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclip
            end
        end
    end
end

local function FindKillsStat()
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then return nil end
    for _, stat in pairs(leaderstats:GetChildren()) do
        if stat:IsA("IntValue") and string.lower(stat.Name):find("kill") then
            return stat
        end
    end
    return nil
end

-- ============================================================
-- JANELA PRINCIPAL FLUENT
-- ============================================================

local Window = Fluent:CreateWindow({
    Title = "🔥 NillG Hub | The Strongest Battlegrounds",
    SubTitle = "por WermdDevs",
    TabWidth = 140,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Farm = Window:AddTab({ Title = "Auto Farm", Icon = "sword" }),
    Kills = Window:AddTab({ Title = "Kill Counter", Icon = "bar-chart-2" }),
    Info = Window:AddTab({ Title = "Informações", Icon = "info" }),
    Settings = Window:AddTab({ Title = "Configurações", Icon = "settings" })
}

-- ============================================================
-- ABA: AUTO FARM
-- ============================================================

Tabs.Farm:AddSection("Farming & Utilitários")

local ToggleAutoReset = Tabs.Farm:AddToggle("AutoReset", { Title = "Auto Reset", Default = false })
ToggleAutoReset:OnChanged(function(value)
    autoReset = value
    if autoReset then
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            if resetConnection then resetConnection:Disconnect() end
            local hum = char:WaitForChild("Humanoid")
            resetConnection = hum.HealthChanged:Connect(function(hp)
                if hp < hum.MaxHealth then
                    hum.Health = 0
                end
            end)
        end
        Fluent:Notify({ Title = "NillG Hub", Content = "✅ AutoReset ATIVADO!", Duration = 3 })
    else
        if resetConnection then
            resetConnection:Disconnect()
            resetConnection = nil
        end
        Fluent:Notify({ Title = "NillG Hub", Content = "❌ AutoReset DESATIVADO!", Duration = 3 })
    end
end)

local ToggleNoclipBtn = Tabs.Farm:AddToggle("Noclip", { Title = "Noclip", Default = false })
ToggleNoclipBtn:OnChanged(function(value)
    ToggleNoclip(value)
    Fluent:Notify({
        Title = "NillG Hub",
        Content = value and "✅ Noclip ATIVADO!" or "❌ Noclip DESATIVADO!",
        Duration = 3
    })
end)

Tabs.Farm:AddButton({
    Title = "📍 Definir Ponto de Spawn",
    Description = "Salva sua posição atual para o respawn",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            spawnPoint = player.Character.HumanoidRootPart.Position
            Fluent:Notify({ Title = "NillG Hub", Content = "✅ Spawn definido com sucesso!", Duration = 3 })
        end
    end
})

Tabs.Farm:AddButton({
    Title = "🚀 Teleport para Arena",
    Description = "Teleporta o jogador diretamente para as coordenadas de farm",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(438.643555, 439.510529, -377.068573)
            ToggleNoclip(true)
            ToggleNoclipBtn:SetValue(true)
            Fluent:Notify({ Title = "NillG Hub", Content = "✅ Teleportado para a Arena!", Duration = 3 })
        end
    end
})

Tabs.Farm:AddSection("Otimização & Servidor")

Tabs.Farm:AddButton({
    Title = "⚡ Ativar Anti Lag",
    Description = "Executa um script de otimização de performance",
    Callback = function()
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/louismich4el/ItsLouisPlayz-Scripts/refs/heads/main/Anti%20Lag%20V2.lua"))()
        end)
        Fluent:Notify({
            Title = "NillG Hub",
            Content = success and "✅ Otimização aplicada!" or "❌ Erro ao carregar: " .. tostring(err),
            Duration = 3
        })
    end
})

Tabs.Farm:AddButton({
    Title = "🔄 Reconectar (Rejoin)",
    Description = "Entra novamente no mesmo servidor",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end
})

Tabs.Farm:AddButton({
    Title = "📉 Limitar FPS (10 FPS)",
    Description = "Ideal para farm em contas secundárias",
    Callback = function()
        setfpscap(10)
        Fluent:Notify({ Title = "NillG Hub", Content = "✅ Limitador ativado para 10 FPS!", Duration = 3 })
    end
})

-- ============================================================
-- ABA: KILL COUNTER
-- ============================================================

Tabs.Kills:AddSection("Estatísticas de Kills")

local KillsParagraph = Tabs.Kills:AddParagraph({
    Title = "📊 Estatísticas em Tempo Real",
    Content = "Carregando estatísticas do jogador..."
})

task.spawn(function()
    killStat = FindKillsStat()
    if killStat then
        startKills = killStat.Value
    end
end)

local elapsedSeconds = 0
task.spawn(function()
    while task.wait(1) do
        elapsedSeconds = elapsedSeconds + 1
        local minutes = math.floor(elapsedSeconds / 60)
        local seconds = elapsedSeconds % 60
        local timeFormatted = string.format("%02d:%02d", minutes, seconds)
        
        local currentKills = killStat and killStat.Value or 0
        local gainedKills = killStat and (currentKills - startKills) or 0
        
        KillsParagraph:SetTitle("📊 Estatísticas em Tempo Real")
        KillsParagraph:SetContent(string.format("Kills Atuais: %d\nKills Ganhas: %d\nTempo Decorrido: %s", currentKills, gainedKills, timeFormatted))
    end
end)

Tabs.Kills:AddButton({
    Title = "🔄 Resetar Contador",
    Description = "Zera a contagem de kills ganhas nesta sessão",
    Callback = function()
        if killStat then
            startKills = killStat.Value
            Fluent:Notify({ Title = "NillG Hub", Content = "✅ Contador de Kills zerado!", Duration = 3 })
        end
    end
})

-- ============================================================
-- ABA: INFORMAÇÕES
-- ============================================================

Tabs.Info:AddSection("Detalhes do Script")

Tabs.Info:AddParagraph({
    Title = "🔥 NillG Hub",
    Content = "Desenvolvido por: WermdDevs\nComunidade: NCG Studios | WermdDevs\n\nFinalidade: Script para automatização de farm de kills em contas secundárias no The Strongest Battlegrounds."
})

Tabs.Info:AddButton({
    Title = "📋 Copiar Link do Discord",
    Description = "Copia o convite da comunidade para a sua área de transferência",
    Callback = function()
        setclipboard("https://discord.gg/yGHsSMCSm7")
        Fluent:Notify({ Title = "NillG Hub", Content = "✅ Link do Discord copiado!", Duration = 3 })
    end
})

-- ============================================================
-- GERENCIADORES FLUENT
-- ============================================================

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

SaveManager:LoadAutoloadConfig()

-- ============================================================
-- CONEXÕES DO PERSONAGEM
-- ============================================================

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    
    if spawnPoint then
        char.HumanoidRootPart.CFrame = CFrame.new(spawnPoint)
    end
    
    if resetConnection then
        resetConnection:Disconnect()
        resetConnection = nil
    end
    
    if autoReset then
        local hum = char:WaitForChild("Humanoid")
        resetConnection = hum.HealthChanged:Connect(function(hp)
            if hp < hum.MaxHealth then
                hum.Health = 0
            end
        end)
    end
    
    if noclip then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

Fluent:Notify({
    Title = "NillG Hub",
    Content = "🔥 Interface Fluent carregada com sucesso!",
    Duration = 5
})
