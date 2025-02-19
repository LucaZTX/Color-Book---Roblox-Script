local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local VirtualInputManager = game:GetService("VirtualInputManager")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local mapName = "Village By Waterfall"
local defaultColor = Color3.fromRGB(230, 230, 230)

-- Lista de ángulos para escanear todas las partes
local angles = {
    {yaw = 0, pitch = 0},       -- Frontal
    {yaw = 90, pitch = 0},      -- Lateral Derecho
    {yaw = -90, pitch = 0},     -- Lateral Izquierdo
    {yaw = 180, pitch = 0},     -- Opuesto
    {yaw = 0, pitch = -90},     -- Desde Arriba
    {yaw = 0, pitch = 90},      -- Desde Abajo
    {yaw = 45, pitch = -45},    -- Diagonal Superior Derecha
    {yaw = -45, pitch = -45}    -- Diagonal Superior Izquierda
}

function isUnpainted(part)
    return part.Color == defaultColor
end

function moveCameraToAngle(part, yaw, pitch)
    camera.CameraType = Enum.CameraType.Scriptable
    local offset = CFrame.Angles(math.rad(pitch), math.rad(yaw), 0) * Vector3.new(4, 2, 4)
    camera.CFrame = CFrame.new(part.Position + offset, part.Position)
end

function equipPaintTool()
    if character and not character:FindFirstChildOfClass("Tool") then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)
    end
end

function clickPart(part)
    local screenPoint, onScreen = camera:WorldToViewportPoint(part.Position)
    if onScreen then
        VirtualInputManager:SendMouseButtonEvent(screenPoint.X, screenPoint.Y, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(screenPoint.X, screenPoint.Y, 0, false, game, 0)
    end
end

function findUnpaintedParts()
    local map = workspace:FindFirstChild(mapName)
    if not map then
        warn("⚠ No se encontró el mapa: " .. mapName)
        return {}
    end

    local partsToPaint = {}

    for _, model in ipairs(map:GetChildren()) do
        if model:IsA("Model") then
            for _, part in ipairs(model:GetDescendants()) do
                if part:IsA("Part") and isUnpainted(part) then
                    table.insert(partsToPaint, part)
                end
            end
        end
    end

    return partsToPaint
end

task.spawn(function()
    equipPaintTool()

    for _, angle in ipairs(angles) do
        local partsToPaint = findUnpaintedParts()
        if #partsToPaint == 0 then break end -- Si ya pintó todo, termina

        print("🎨 Pintando desde ángulo: Yaw", angle.yaw, "Pitch", angle.pitch)

        for _, part in ipairs(partsToPaint) do
            moveCameraToAngle(part, angle.yaw, angle.pitch)
            clickPart(part)
            task.wait(0.03) -- Velocidad ajustada para evitar crasheos
        end

        task.wait(0.4) -- Breve pausa entre cambios de ángulo
    end

    print("✅ ¡Todo el mapa ha sido pintado!")

    camera.CameraType = Enum.CameraType.Custom -- Restaura la cámara
end)
