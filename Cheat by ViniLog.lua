-- Загрузка библиотеки Kavo UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Проверка успешной загрузки библиотеки Kavo
if not Library then
    warn("Ошибка загрузки библиотеки Kavo UI! Проверьте URL.")
    return
end

-- Создание главного окна
local Window = Library.CreateLib("VCom Team • Владелец @ViniLog", "BloodTheme")

-- Создание вкладок
local FunTab = Window:NewTab("Фан")
local MovementTab = Window:NewTab("Движение")
local RageTab = Window:NewTab("Рэдж")
local TeleportTab = Window:NewTab("Телепорт")

-- Создание секций внутри вкладок
local MovementSection = MovementTab:NewSection("Управление Движением")
local FlySection = MovementTab:NewSection("Настройки Полёта")
local FunSection = FunTab:NewSection("Фан Функции")
local RageSection = RageTab:NewSection("Опции Рэджа")
local TeleportSection = TeleportTab:NewSection("Опции Телепорта")

-- Переменные для изменения игрока
local walkSpeed = 30
local jumpMultiplier = 1.0
local flyEnabled = false
local flySpeed = 20
local speedHackEnabled = false
local speedMultiplier = 1.0
local forceFieldEnabled = false
local noclipEnabled = false
local fallDamageEnabled = true
local spinEnabled = false
local spinSpeed = 10
local playerSizeMultiplier = 1.0

-- Координаты безопасной зоны
local safeZoneCoordinates = Vector3.new(-298, 179, 307)

-- Переменные для управления полётом
local flyControlVelocity = Vector3.new(0, 0, 0)
local flyUpKey = Enum.KeyCode.Space
local flyDownKey = Enum.KeyCode.LeftShift
local flyForwardKey = Enum.KeyCode.W
local flyBackwardKey = Enum.KeyCode.S
local flyLeftKey = Enum.KeyCode.A
local flyRightKey = Enum.KeyCode.D

-- Переменные для телепортации
local teleportToMouseEnabled = false

-- Функция для применения скорости ходьбы с плавным переходом
local function applyWalkSpeed()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        local targetSpeed = walkSpeed * speedMultiplier
        humanoid.WalkSpeed = targetSpeed
    end
end

-- Функция для применения силы прыжка с множителем
local function applyJumpPower()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        local targetJump = 50 * jumpMultiplier
        humanoid.JumpPower = targetJump
    end
end

-- Функция для включения/выключения режима полёта
local function toggleFly()
    flyEnabled = not flyEnabled
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart then
            humanoid.PlatformStand = flyEnabled
            if flyEnabled then
                game:GetService("RunService").RenderStepped:Connect(function()
                    if flyEnabled and rootPart then
                        local camera = game.Workspace.CurrentCamera
                        local forwardVector = camera.CFrame.LookVector
                        local rightVector = camera.CFrame.RightVector
                        local upVector = Vector3.new(0, 1, 0)
                        flyControlVelocity = Vector3.new(0, 0, 0)
                        if game:GetService("UserInputService"):IsKeyDown(flyForwardKey) then
                            flyControlVelocity += forwardVector
                        end
                        if game:GetService("UserInputService"):IsKeyDown(flyBackwardKey) then
                            flyControlVelocity -= forwardVector
                        end
                        if game:GetService("UserInputService"):IsKeyDown(flyLeftKey) then
                            flyControlVelocity -= rightVector
                        end
                        if game:GetService("UserInputService"):IsKeyDown(flyRightKey) then
                            flyControlVelocity += rightVector
                        end
                        if game:GetService("UserInputService"):IsKeyDown(flyUpKey) then
                            flyControlVelocity += upVector
                        end
                        if game:GetService("UserInputService"):IsKeyDown(flyDownKey) then
                            flyControlVelocity -= upVector
                        end
                        rootPart.Velocity = flyControlVelocity * flySpeed
                    end
                end)
            else
                rootPart.Velocity = Vector3.new(0, 0, 0)
                  for _, connection in pairs(game:GetService("RunService"):GetSteppedSignal():GetConnections()) do
                  connection:Disconnect()
                 end
            end
        end
    end
end

-- Функция для включения/выключения спидхака
local function toggleSpeedHack()
    speedHackEnabled = not speedHackEnabled
    if not speedHackEnabled then
        applyWalkSpeed()
    end
end

-- Функция для включения/выключения силового поля
local function toggleForceField()
    forceFieldEnabled = not forceFieldEnabled
    local player = game.Players.LocalPlayer
    if player and player.Character then
        local forceField = player.Character:FindFirstChild("ForceField")
        if forceField then
            forceField:Destroy()
        elseif forceFieldEnabled then
            Instance.new("ForceField").Parent = player.Character
        end
    end
end

-- Функция для телепортации в безопасную зону
local function teleportToSafeZone()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(safeZoneCoordinates)
    else
        warn("Игрок или HumanoidRootPart не найдены.")
    end
end

-- Функция для включения/выключения режима прохождения сквозь стены
local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    local player = game.Players.LocalPlayer
    if player and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not noclipEnabled
            end
        end
    end
end

-- Функция для включения/выключения урона от падения
local function toggleFallDamage()
    fallDamageEnabled = not fallDamageEnabled
end

-- Функция для обновления и отображения координат
local function updateCoordinates()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local position = player.Character.HumanoidRootPart.Position
        local coordinatesText = string.format("X: %.2f, Y: %.2f, Z: %.2f", position.X, position.Y, position.Z)
        -- InfoSection:SetLabel("Coordinates", coordinatesText) -- Закомментировано как запрошено
    else
        -- InfoSection:SetLabel("Coordinates", "Координаты недоступны") -- Закомментировано как запрошено
    end
end

-- Функция для телепортации к курсору мыши (один раз по нажатию ЛКМ)
local function teleportToMouse()
    local player = game.Players.LocalPlayer
    local mouse = player:GetMouse()
    local mouseHit = mouse.Target
    if teleportToMouseEnabled and player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and mouseHit then
        player.Character.HumanoidRootPart.CFrame = mouseHit.CFrame * CFrame.new(0, 2, 0)
    end
end
-- Функция для включения/выключения телепорта к мыши (режим)
local function toggleTeleportToMouse()
     teleportToMouseEnabled = not teleportToMouseEnabled
end

-- Функция для включения/выключения вращения игрока с регулируемой скоростью
local function toggleSpin()
    spinEnabled = not spinEnabled
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        if spinEnabled then
            game:GetService("RunService").RenderStepped:Connect(function()
                if spinEnabled and rootPart then
                    rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                end
            end)
        else
            for _, connection in pairs(rootPart:GetPropertyChangedSignal("CFrame"):GetConnections()) do
                connection:Disconnect()
            end
        end
    end
end

-- Функция для увеличения головы
local function bigHead()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Head") then
        local head = player.Character.Head
        local originalSize = head.Size
        head.Size = originalSize * 3
        local debounce = false
        spawn(function()
            wait(5)
            if not debounce then
                debounce = true
                head.Size = originalSize
            end
        end)
    end
end

-- Функция для создания эффекта прыгучести персонажа
local function makeBouncy()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local originalMass = rootPart.Mass
        local originalMaterial = rootPart.Material
        
        rootPart.Mass = 1
        rootPart.Material = Enum.Material.Ice
        local debounce = false
        spawn(function()
            wait(5)
            if not debounce then
                debounce = true
                rootPart.Mass = originalMass
                rootPart.Material = originalMaterial
            end
        end)
    end
end

-- Функция для превращения игрока в тряпичную куклу
local function ragdollPlayer()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        local originalState = humanoid:GetState()
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        local debounce = false
        spawn(function()
            wait(5)
            if not debounce then
                debounce = true
                humanoid:ChangeState(originalState)
            end
        end)
    end
end

-- Новые Полезные Функции

-- Функция для включения/выключения режима бога
local function godMode()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        if not humanoid:FindFirstChild("GodMode") then
            local godModeTag = Instance.new("BoolValue")
            godModeTag.Name = "GodMode"
            godModeTag.Parent = humanoid
            local connection
            connection = humanoid.HealthChanged:Connect(function(health)
                if health <= 0 then
                    humanoid.Health = 100
                end
            end)
            godModeTag.Changed:Connect(function(value)
                if not value then
                    connection:Disconnect()
                    godModeTag:Destroy()
                end
            end)
        else
            humanoid:FindFirstChild("GodMode"):Destroy()
        end
    end
end

-- Функция для бесконечного прыжка
local function infiniteJump()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        local connection
        if not humanoid:FindFirstChild("InfiniteJump") then
            local infiniteJumpTag = Instance.new("BoolValue")
            infiniteJumpTag.Name = "InfiniteJump"
            infiniteJumpTag.Parent = humanoid
            connection = humanoid.StateChanged:Connect(function(oldState, newState)
                if newState == Enum.HumanoidStateType.Landed then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
            infiniteJumpTag.Changed:Connect(function(value)
                if not value then
                    connection:Disconnect()
                    infiniteJumpTag:Destroy()
                end
            end)
        else
            humanoid:FindFirstChild("InfiniteJump"):Destroy()
        end
    end
end

-- Функция для создания платформы
local function createPlatform()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = player.Character.HumanoidRootPart
        local platform = Instance.new("Part")
        platform.Size = Vector3.new(5,0.5,5)
        platform.CFrame = rootPart.CFrame * CFrame.new(0,-3,0)
        platform.Anchored = true
        platform.Parent = game.Workspace
        game:GetService("Debris"):AddItem(platform, 10)
    end
end

-- Функция для исправления персонажа
local function fixCharacter()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        humanoid:UnequipTools()
        if humanoid:GetState() == Enum.HumanoidStateType.Physics then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

-- Функция для изменения размера игрока
local function changePlayerSize()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        if playerSizeMultiplier == 1 then
            humanoid.HipHeight = 2
        else
            humanoid.HipHeight = 2 * playerSizeMultiplier
        end
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if playerSizeMultiplier == 1 then
                    part.Size = part:GetAttribute("OriginalSize")
                else
                    part.Size = part:GetAttribute("OriginalSize") * playerSizeMultiplier
                end
            end
        end
    end
end


-- Новые Функции Ярости

-- Функция для уничтожения частей тела ближайших игроков
local function destroyNearbyPlayers(radius)
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local rootPart = player.Character.HumanoidRootPart
    local position = rootPart.Position

    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local targetRootPart = p.Character.HumanoidRootPart
            local targetPosition = targetRootPart.Position
            local distance = (position - targetPosition).Magnitude
            if distance <= radius then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part:Destroy()
                    end
                end
            end
        end
    end
end

-- Функция для бесконечного взлёта
local function infiniteYield()
    while true do
        task.wait()
        local player = game.Players.LocalPlayer
        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Velocity = Vector3.new(0,100,0)
        end
    end
end

-- Функция для создания взрыва
local function createExplosion(radius)
    local player = game.Players.LocalPlayer
    if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = player.Character.HumanoidRootPart
    local position = rootPart.Position
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = radius
    explosion.DestroyJointRadiusPercent = 0
    explosion.BlastPressure = 5000000
    explosion.Parent = game.Workspace
    
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Humanoid") then
            local humanoid = p.Character.Humanoid
            local distance = (position - p.Character.HumanoidRootPart.Position).Magnitude
            if distance <= radius then
                local damage = 100 * (1 - distance / radius)
                humanoid.Health -= damage
            end
        end
    end
end


-- Обработка урона от падения
local function handleFallDamage()
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character:FindFirstChild("Humanoid") then
        local humanoid = player.Character.Humanoid
        humanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Landed and oldState == Enum.HumanoidStateType.Freefall then
                if humanoid.Health > 0 and fallDamageEnabled then
                    local fallDamage =  math.floor(math.abs(player.Character.HumanoidRootPart.Velocity.Y) * 0.35)
                    humanoid:TakeDamage(fallDamage)
                end
            end
        end)
    end
end
local function checkCharacterSize()
    local player = game.Players.LocalPlayer
    if player and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and not part:GetAttribute("OriginalSize") then
                part:SetAttribute("OriginalSize", part.Size)
            end
        end
    end
end

-- Элементы UI
MovementSection:NewSlider("Скорость Ходьбы", "Установите вашу скорость ходьбы", 500, 30, function(value)
    walkSpeed = value
    applyWalkSpeed()
end)

MovementSection:NewSlider("Множитель Прыжка", "Установите множитель прыжка", 5, 1, function(value)
    jumpMultiplier = value
    applyJumpPower()
end)

FlySection:NewToggle("Полёт", "Включить режим полёта", function()
    toggleFly()
end)

FlySection:NewSlider("Скорость Полётa", "Установите скорость полёта", 100, 20, function(value)
    flySpeed = value
end)

FunSection:NewToggle("Силовое Поле", "Включить силовое поле", function()
    toggleForceField()
end)

FunSection:NewToggle("Спидхак", "Включить множитель скорости", function()
    toggleSpeedHack()
end)

FunSection:NewSlider("Множитель Скорости", "Установите множитель скорости", 5, 1, function(value)
    speedMultiplier = value
    if speedHackEnabled then
        applyWalkSpeed()
    end
end)
FunSection:NewSlider("Размер Персонажа", "Установите размер персонажа", 5, 1, function(value)
   playerSizeMultiplier = value
    changePlayerSize()
end)
FunSection:NewButton("Большая Голова", "Сделайте вашу голову ОГРОМНОЙ!", function()
    bigHead()
end)

FunSection:NewButton("Прыгучесть", "Сделайте вашего персонажа Прыгучим!", function()
    makeBouncy()
end)

FunSection:NewButton("Тряпичная Кукла", "Сделайте вашего персонажа Тряпичной Куклой", function()
    ragdollPlayer()
end)

FunSection:NewButton("Режим Бога", "Сделайте себя Неуязвимым", function()
    godMode()
end)
FunSection:NewButton("Бесконечный Прыжок", "Позволяет прыгать бесконечно", function()
    infiniteJump()
end)
FunSection:NewButton("Создать Платформу", "Создаёт платформу под вами", function()
    createPlatform()
end)
FunSection:NewButton("Исправить Персонажа", "Возвращает вашего персонажа в хорошее состояние", function()
    fixCharacter()
end)

FunSection:NewSlider("Скорость Вращения", "Установите скорость вращения", 180, 10, function(value)
    spinSpeed = value
end)

FunSection:NewToggle("Вращение", "Включить вращение игрока", function()
    toggleSpin()
end)

RageSection:NewToggle("Noclip", "Включить режим прохождения сквозь стены", function()
    toggleNoclip()
end)

RageSection:NewButton("Убрать игроков рядом (визуал)", "Убирает части тела ближайших игроков (20 стад)", function()
    destroyNearbyPlayers(20)
end)
RageSection:NewButton("Бесконечный Взлёт", "Заставляет вашего игрока взлетать вверх (очень быстро)", function()
    infiniteYield()
end)
RageSection:NewButton("Создать Взрыв", "Создаёт взрыв вокруг вас (10 стад)", function()
   createExplosion(10)
end)

TeleportSection:NewButton("Телепорт в Безопасную Зону", "Телепортирует вас в (-298, 179, 307)", function()
    teleportToSafeZone()
end)
TeleportSection:NewToggle("Телепорт к Мыши", "Вкл/Выкл телепорт к мыши", function()
    toggleTeleportToMouse()
end)

-- Initialization
applyWalkSpeed()
applyJumpPower()
handleFallDamage()
checkCharacterSize()
fallDamageEnabled = true

-- Главный цикл для применения изменений
game:GetService("RunService").Stepped:Connect(function()
    if speedHackEnabled then
        applyWalkSpeed()
    end
    updateCoordinates()
    changePlayerSize()
end)

-- Включение/выключение меню
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if Window.Enabled then
            Window.Toggle(false)
        else
            Window.Toggle(true)
        end
    end
end)

-- Закрытие меню кнопкой X
Window.Window.CloseButton.MouseButton1Down:Connect(function()
    Window.Toggle(false)
end)

-- Обработка клика мыши для телепортации (один раз)
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        teleportToMouse()
    end
end)

-- Список всех функций на русском языке:
-- Скорость ходьбы: Устанавливает скорость ходьбы персонажа.
-- Множитель прыжка: Устанавливает высоту прыжка персонажа.
-- Полёт: Включает или выключает режим полета.
-- Скорость полёта: Устанавливает скорость полета персонажа.
-- Силовое поле: Включает или выключает силовое поле вокруг персонажа, защищающее его от урона.
-- Спидхак: Включает или выключает множитель скорости ходьбы.
-- Множитель скорости: Устанавливает множитель скорости ходьбы.
-- Размер персонажа: Устанавливает размер персонажа.
-- Большая голова: Делает голову персонажа очень большой.
-- Прыгучесть: Делает персонажа очень прыгучим и скользким.
-- Тряпичная кукла: Превращает персонажа в тряпичную куклу.
-- Режим бога: Делает персонажа неуязвимым к урону.
-- Бесконечный прыжок: Позволяет персонажу прыгать бесконечно.
-- Создать платформу: Создает платформу под персонажем.
-- Исправить персонажа: Возвращает персонажа в нормальное состояние.
-- Скорость вращения: Устанавливает скорость вращения персонажа.
-- Вращение: Включает или выключает вращение персонажа.
-- Noclip: Включает или выключает режим прохождения сквозь стены.
-- Убрать игроков рядом: Убирает части тела ближайших игроков.
-- Бесконечный взлёт: Заставляет персонажа бесконечно взлетать.
-- Создать взрыв: Создает взрыв вокруг персонажа.
-- Телепорт в безопасную зону: Телепортирует персонажа в безопасную зону.
-- Телепорт к Мыши: Включает или выключает режим телепортации к мышке (один раз при нажатии ЛКМ).